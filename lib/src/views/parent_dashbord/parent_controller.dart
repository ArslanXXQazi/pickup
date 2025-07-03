import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/utills/snackbar.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import 'package:pick_up_pal/src/views/teacher_dashbord_view/teacher_controller/teacher_controller.dart';

class ParentController extends GetxController {
  var isLoading = false.obs;
  var childLoading = <String, bool>{}.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final UserId userIdController = Get.find<UserId>();

  final selectedGender = RxString('');
  final selectedPickup = RxString('');
  final selectedBus = RxString('');
  final selectedGrade = RxList<String>([]);
  final gender = ['Male', 'Female', 'Other'].obs;
  final pickup = ['Self Pickup', 'Driver Pickup'].obs;
  final buses = ['Bus 1', 'Bus 2', 'Bus 3'].obs;
  final grades = [
    'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5',
    'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'
  ].obs;

  // Initialize TeacherController
  final TeacherController teacherController = Get.put(TeacherController());

  /// List to store pickup history for the current user
  var pickupHistoryList = <Map<String, dynamic>>[].obs;

  /// Loading state for pickup history
  var isHistoryLoading = false.obs;

  /// List to store pickup notifications for the current user
  var pickupNotificationsList = <Map<String, dynamic>>[].obs;

  var lastNotificationId = ''.obs;

  /// Fetch pickup history for the current user (last 7 days)
  Future<void> fetchPickupHistory() async {
    try {
      isHistoryLoading.value = true;
      String userId = userIdController.userId.value;
      final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
      final snapshot = await FirebaseFirestore.instance
          .collection('pickupHistory')
          .where('userId', isEqualTo: userId)
          .where('pickupTime', isGreaterThan: oneWeekAgo.toIso8601String())
          .orderBy('pickupTime', descending: true)
          .get();
      pickupHistoryList.value = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching pickup history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void addChild() async {
    try {
      isLoading.value = true;
      String userId = userIdController.userId.value;
      String assignedDriverId = '';
      // Agar pickup Driver Pickup hai, toh bus ke basis par driver ka userId nikaalo
      if (selectedPickup.value == 'Driver Pickup' && selectedBus.value.isNotEmpty) {
        // Firestore se driver nikaalo jiska busses == selectedBus.value
        var driverQuery = await FirebaseFirestore.instance
            .collection('userData')
            .where('busses', isEqualTo: selectedBus.value)
            .where('role', isEqualTo: 'Driver')
            .get();
        if (driverQuery.docs.isNotEmpty) {
          assignedDriverId = driverQuery.docs.first.data()['userId'] ?? '';
        }
      }
      await FirebaseFirestore.instance.collection("addChild").doc().set({
        "userId": userId,
        "childName": nameController.text,
       // "school": schoolController.text,
        "class": selectedGrade.isNotEmpty ? selectedGrade[0] : '',
        "age": ageController.text,
        "gender": selectedGender.value,
        "pickup": selectedPickup.value,
        "bus": selectedPickup.value == 'Driver Pickup' ? selectedBus.value : '',
        "image": "",
        "pickedUp": false,
        "assignedDriverId": assignedDriverId, // Yeh field add ki
      });
      Get.back();
      Get.find<UserId>().getChildData();
      NotificationMessage.show(
        title: "Success",
        message: "Child Added Successfully",
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
      isLoading.value = false;
      clear();
    } catch (e) {
      isLoading.value = false;
      NotificationMessage.show(
        title: "Error",
        message: e.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void clear() {
    nameController.clear();
    schoolController.clear();
    ageController.clear();
    selectedGender.value = '';
    selectedPickup.value = '';
    selectedBus.value = '';
    selectedGrade.clear();
  }

  void notifySchool(String childId) async {
    try {
      childLoading[childId] = true;
      await FirebaseFirestore.instance.collection("addChild").doc(childId).update({
        "parentNotified": true,
      });
      // Fetch child data for notification
      var doc = await FirebaseFirestore.instance.collection("addChild").doc(childId).get();
      var data = doc.data();
      if (data != null) {
        String childName = data['childName'] ?? '';
        String className = data['class'] ?? '';
        // Query teacher with this class
        var teacherQuery = await FirebaseFirestore.instance
            .collection('userData')
            .where('role', isEqualTo: 'Teacher')
            .where('classes', arrayContains: className)
            .get();
        if (teacherQuery.docs.isNotEmpty) {
          String teacherId = teacherQuery.docs.first.id;
          await FirebaseFirestore.instance.collection('teacherNotifications').add({
            'teacherId': teacherId,
            'childName': childName,
            'message': 'Parent of $childName has arrived at school.',
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }
      teacherController.fetchPickupQueueStudents(); // Use initialized controller
      NotificationMessage.show(
        title: "Success",
        message: "School notified successfully",
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      NotificationMessage.show(
        title: "Error",
        message: e.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      childLoading[childId] = false;
    }
  }

  /// Save pickup history when a child is picked up
  Future<void> savePickupHistory({
    required String childId,
    required String childName,
    required String userId,
  }) async
  {
    try {
      await FirebaseFirestore.instance.collection('pickupHistory').add({
        'childId': childId,
        'childName': childName,
        'userId': userId,
        'pickupTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving pickup history: $e');
    }
  }

  /// Clean up pickup history older than 7 days
  Future<void> cleanupOldPickupHistory() async {
    try {
      final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
      final snapshot = await FirebaseFirestore.instance
          .collection('pickupHistory')
          .where('pickupTime', isLessThan: oneWeekAgo.toIso8601String())
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error cleaning up old pickup history: $e');
    }
  }

  /// Update pickedUp and save history if pickedUp is true
  Future<void> setPickedUp(String childId, bool pickedUp) async {
    try {
      await FirebaseFirestore.instance.collection('addChild').doc(childId).update({
        'pickedUp': pickedUp,
      });
      if (pickedUp) {
        // Find child name and userId
        int idx = userIdController.childIds.indexOf(childId);
        String childName = idx != -1 ? userIdController.childNames[idx] : '';
        String userId = userIdController.userId.value;
        await savePickupHistory(childId: childId, childName: childName, userId: userId);
        await cleanupOldPickupHistory();
      }
    } catch (e) {
      print('Error updating pickedUp: $e');
    }
  }

  /// Save pickup notification when a child is picked up
  Future<void> savePickupNotification({
    required String userId,
    required String childName,
    required String message,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('pickupNotifications').add({
        'userId': userId,
        'childName': childName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving pickup notification: $e');
    }
  }

  /// Fetch pickup notifications for the current user (last 7 days)
  Future<void> fetchPickupNotifications() async {
    try {
      String userId = userIdController.userId.value;
      final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
      final snapshot = await FirebaseFirestore.instance
          .collection('pickupNotifications')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: oneWeekAgo.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();
      pickupNotificationsList.value = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching pickup notifications: $e');
    }
  }

  /// Clean up pickup notifications older than 7 days
  Future<void> cleanupOldPickupNotifications() async {
    try {
      final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
      final snapshot = await FirebaseFirestore.instance
          .collection('pickupNotifications')
          .where('timestamp', isLessThan: oneWeekAgo.toIso8601String())
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error cleaning up old pickup notifications: $e');
    }
  }
}