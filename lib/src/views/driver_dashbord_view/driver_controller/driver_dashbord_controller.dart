import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import 'package:pick_up_pal/src/utills/snackbar.dart';
import '../../track_pickup/google_map_controller.dart';

class DriverController extends GetxController {
  var driverName = "".obs;
  var driverEmail = "".obs;
  var assignedChildren = <Map<String, String>>[].obs;
  var bus = <Map<String, String>>[].obs;
  var isLoading = true.obs;
  /// Per-student loading state for status update
  var childStatusLoading = <String, bool>{}.obs;
  /// Track which button is loading in the dialog (docId+status)
  var loadingStatusButton = ''.obs;
  var isLocationShared = true.obs;
  var lastNotificationId = ''.obs;

  final UserId userIdController = Get.find<UserId>();

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchLocationSharing();
  }

  void fetchData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchDriverData(),
        fetchAssignedChildren(),
      ]);
      isLoading.value = false;
    } catch (e) {
      print('------Error fetching data: ${e.toString()}');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void fetchLocationSharing() async {
    String userId = userIdController.userId.value;
    var doc = await FirebaseFirestore.instance.collection('userData').doc(userId).get();
    if (doc.exists) {
      isLocationShared.value = doc.data()?['locationSharing'] ?? true;
    }
  }

  void toggleLocationSharing(bool value) async {
    isLocationShared.value = value;
    String userId = userIdController.userId.value;
    await FirebaseFirestore.instance.collection('userData').doc(userId).update({
      'locationSharing': value,
    });
  }

  Future<void> fetchDriverData() async {
    await userIdController.getUserIdAndRole();
    driverName.value = userIdController.userName.value;
    driverEmail.value = userIdController.userEmail.value;
    print('------Fetched Driver Name: ${driverName.value}');
    print('------Fetched Driver Email: ${driverEmail.value}');
  }

  void _sortAssignedChildren() {
    assignedChildren.sort((a, b) {
      int getOrder(Map<String, String> student) {
        if (student['status'] == 'Onboard') return 0; // top
        if (student['status'] == 'Not Picked Up') return 1; // middle
        if (student['status'] == 'Dropped Off') return 2; // end
        return 3;
      }
      int orderA = getOrder(a);
      int orderB = getOrder(b);
      if (orderA != orderB) return orderA.compareTo(orderB);
      return (a['childName'] ?? '').compareTo(b['childName'] ?? '');
    });
  }

  Future<void> fetchAssignedChildren() async {
    try {
      await userIdController.getUserIdAndRole();
      print('DEBUG: userId: ' + userIdController.userId.value);
      if (userIdController.userId.value.isEmpty) {
        print('------No user ID available');
        assignedChildren.clear();
        return;
      }

      var driverDoc = await FirebaseFirestore.instance
          .collection("userData")
          .doc(userIdController.userId.value)
          .get();
      print('DEBUG: driverDoc: ' + driverDoc.data().toString());

      if (!driverDoc.exists) {
        print('------No driver data found in Firestore');
        assignedChildren.clear();
        return;
      }

      String assignedBus = driverDoc.data()?['busses'] ?? "";
      print('------Driver assigned bus: $assignedBus');

      if (assignedBus.isEmpty) {
        print('------No bus assigned to driver');
        assignedChildren.clear();
        return;
      }

      var childDocs = await FirebaseFirestore.instance
          .collection("addChild")
          .where('bus', isEqualTo: assignedBus.trim())
          .get();
      print('DEBUG: childDocs found: ' + childDocs.docs.length.toString());
      assignedChildren.clear();
      if (childDocs.docs.isEmpty) {
        print('------No children found for bus: $assignedBus');
      } else {
        for (var doc in childDocs.docs) {
          var data = doc.data();
          print('DEBUG: child doc data: ' + data.toString());
          String childName = data?['childName'] ?? "N/A";
          String status = data?['status'] ?? "Not Picked Up";

          // 1. dropMarker ka reset: 7 min pe (status na badlo)
          if (status == 'Dropped Off' && data.containsKey('dropMarker') && data['dropMarker'] != null) {
            var dropMarkerData = data['dropMarker'];
            dynamic droppedAtRaw = dropMarkerData['droppedAt'];
            DateTime droppedAt;
            if (droppedAtRaw is Timestamp) {
              droppedAt = droppedAtRaw.toDate();
            } else if (droppedAtRaw is String) {
              droppedAt = DateTime.tryParse(droppedAtRaw) ?? DateTime.now().subtract(Duration(minutes: 2));
            } else {
              droppedAt = DateTime.now().subtract(Duration(minutes: 2));
            }
            // Sirf marker ko 7 min baad hatao, status na badlo
            if (DateTime.now().difference(droppedAt).inMinutes >= 7) {
              await FirebaseFirestore.instance.collection('addChild').doc(doc.id).update({
                'dropMarker': null,
              });
              print('------Auto-reset: $childName dropMarker removed after 7 min');
            }
          }

          // 2. driverResetAt ka reset: 10 min pe (status + marker dono reset)
          if (data != null && data['driverResetAt'] != null) {
            dynamic driverResetAtRaw = data['driverResetAt'];
            DateTime driverResetAt;
            if (driverResetAtRaw is Timestamp) {
              driverResetAt = driverResetAtRaw.toDate();
            } else if (driverResetAtRaw is String) {
              driverResetAt = DateTime.tryParse(driverResetAtRaw) ?? DateTime.now();
            } else {
              driverResetAt = DateTime.now();
            }
            if (DateTime.now().isAfter(driverResetAt)) {
              await FirebaseFirestore.instance.collection('addChild').doc(doc.id).update({
                'status': 'Not Picked Up',
                'updatedAt': Timestamp.now(),
                'dropMarker': null, // Remove yellow marker
                'driverResetAt': null,
                'droppedOffAt': null,
              });
              status = 'Not Picked Up';
            }
          }

          assignedChildren.add({
            'childName': childName,
            'status': status,
            'docId': doc.id,
          });
          print('------Fetched child: $childName with status: $status');
        }
      }
      _sortAssignedChildren();
    } catch (e) {
      print('------Error fetching assigned children: ${e.toString()}');
      assignedChildren.clear();
      throw e;
    }
  }

  Future<void> updateChildStatus(String docId, String status, {VoidCallback? onComplete}) async {
    try {
      loadingStatusButton.value = docId + status;
      await FirebaseFirestore.instance
          .collection("addChild")
          .doc(docId)
          .update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
      print('------Updated status for docId: $docId to $status');
      // Fetch child name and userId for notification/history
      var doc = await FirebaseFirestore.instance.collection("addChild").doc(docId).get();
      String childName = doc.data()?['childName'] ?? 'the child';
      String userId = doc.data()?['userId'] ?? '';
      // Friendly notification message
      String message = '';
      if (status == 'Onboard') {
        message = "$childName is now Onboard.";
      } else if (status == 'Dropped Off') {
        message = "$childName has been Dropped Off.";
      } else if (status == 'Not Picked Up') {
        message = "$childName is marked as Not Picked Up.";
      } else {
        message = "Status for $childName has been changed to '$status'.";
      }
      // Save notification for parent
      await FirebaseFirestore.instance.collection('pickupNotifications').add({
        'userId': userId,
        'childName': childName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'driverStatus',
        'forRole': 'driver',
      });
      // Save pickup history for Onboard and Dropped Off
      if (status == 'Onboard' || status == 'Dropped Off') {
        await FirebaseFirestore.instance.collection('pickupHistory').add({
          'childId': docId,
          'childName': childName,
          'userId': userId,
          'status': status,
          'pickupTime': DateTime.now().toIso8601String(),
        });
      }
      NotificationMessage.show(
        title: "Status Updated",
        message: message,
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
      fetchAssignedChildren();
      // If status is Dropped Off, auto-reset after 1 hour
      if (status == 'Dropped Off') {
        // Add yellow marker on map (for driver side, already handled)
        double dropLat = 0.0;
        double dropLng = 0.0;
        if (Get.isRegistered<GoogleMapControllerX>()) {
          final mapController = Get.find<GoogleMapControllerX>();
          mapController.addDropMarker(
            lat: mapController.latitude.value,
            lng: mapController.longitude.value,
            childName: childName,
          );
          dropLat = mapController.latitude.value;
          dropLng = mapController.longitude.value;
        } else {
          // Fallback: try to get from Firestore (not ideal, but prevents error)
          var driverDoc = await FirebaseFirestore.instance.collection('userData').doc(userIdController.userId.value).get();
          dropLat = driverDoc.data()?['latitude'] ?? 0.0;
          dropLng = driverDoc.data()?['longitude'] ?? 0.0;
        }
        // Add dropMarker field in addChild document for parent side
        await FirebaseFirestore.instance.collection('addChild').doc(docId).update({
          'dropMarker': {
            'lat': dropLat,
            'lng': dropLng,
            'droppedAt': DateTime.now().toIso8601String(),
            'childName': childName,
          },
          'driverResetAt': DateTime.now().add(Duration(minutes: 10)).toIso8601String(),
          'droppedOffAt': DateTime.now().toIso8601String(),
        });
      }
      Get.find<UserId>().getChildStatusStream(); // Force real-time UI update

      if (onComplete != null) onComplete();
    } catch (e) {
      print('------Error updating child status: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loadingStatusButton.value = '';
    }
  }

  // Add this method to update driver's location in Firestore
  Future<void> updateDriverLocation(double latitude, double longitude) async {
    try {
      String userId = userIdController.userId.value;
      await FirebaseFirestore.instance.collection('userData').doc(userId).update({
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('Error updating driver location: '
          '[31m$e[0m');
    }
  }
}