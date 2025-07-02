import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/parent_controller.dart';
import 'dart:async';

class TeacherController extends GetxController {
  final UserId userIdController = Get.find<UserId>();
  var teacherName = ''.obs;
  var assignedClasses = <String>[].obs;
  var pickupQueueStudents = <Map<String, dynamic>>[].obs;
  var arrivedParentsCount = 0.obs; // Track number of parents who arrived
  var isLoadingPickup = false.obs;
  var completedPickupsCount = 0.obs;
  var loadingPickupChildId = ''.obs;
  var lastNotificationId = ''.obs;
  StreamSubscription? _pickupQueueSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchTeacherData();
    ever(assignedClasses, (_) {
      fetchPickupQueueStudents();
      listenToPickupQueue();
    });
    listenToPickupQueue();
  }

  Future<void> fetchTeacherData() async {
    try {
      String userId = userIdController.userId.value;
      if (userId.isEmpty) {
        await userIdController.getUserIdAndRole();
        userId = userIdController.userId.value;
      }

      if (userId.isNotEmpty) {
        var userDoc = await FirebaseFirestore.instance
            .collection('userData')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          teacherName.value = userDoc['name'] ?? 'Teacher';
          assignedClasses.value = List<String>.from(userDoc['classes'] ?? []);
          print('Assigned classes fetched: ${assignedClasses.value}');
        } else {
          teacherName.value = 'Teacher';
          assignedClasses.clear();
          print('No user data found for teacher');
        }
      } else {
        teacherName.value = 'Teacher';
        assignedClasses.clear();
        print('No user ID available');
      }
    } catch (e) {
      print('Error fetching teacher data: $e');
      teacherName.value = 'Teacher';
      assignedClasses.clear();
    }
  }

  Future<void> fetchPickupQueueStudents() async {
    try {
      if (assignedClasses.isEmpty) {
        pickupQueueStudents.clear();
        arrivedParentsCount.value = 0;
        print('No assigned classes, clearing pickup queue');
        return;
      }

      print('Fetching students for classes: ${assignedClasses.join(', ')}');
      var querySnapshot = await FirebaseFirestore.instance
          .collection('addChild')
          .where('class', whereIn: assignedClasses)
          .where('pickup', isEqualTo: 'Self Pickup')
          .get();

      pickupQueueStudents.clear();
      arrivedParentsCount.value = 0;
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        print('Student document data: $data');
        bool parentNotified = data['parentNotified'] ?? false;
        bool pickedUp = data['pickedUp'] ?? false;
        pickupQueueStudents.add({
          'childName': data['childName']?.toString() ?? 'N/A',
          'description': parentNotified ? 'Parent Arrived' : 'Waiting for pickup',
          'parentNotified': parentNotified,
          'pickedUp': pickedUp,
          'childId': doc.id,
        });
        if (parentNotified && !pickedUp) {
          arrivedParentsCount.value++;
        }
      }
    } catch (e) {
      print('Error fetching pickup queue students: $e');
      pickupQueueStudents.clear();
      arrivedParentsCount.value = 0;
    }
  }

  Future<void> markPickup(String childId) async {
    try {
      loadingPickupChildId.value = childId;
      await FirebaseFirestore.instance.collection("addChild").doc(childId).update({
        "pickedUp": true,
      });
      // Fetch childName and userId for history
      var doc = await FirebaseFirestore.instance.collection("addChild").doc(childId).get();
      var data = doc.data();
      if (data != null) {
        String childName = data['childName'] ?? '';
        String userId = data['userId'] ?? '';
        // Save pickup history using ParentController
        await Get.find<ParentController>().savePickupHistory(
          childId: childId,
          childName: childName,
          userId: userId,
        );
        await Get.find<ParentController>().cleanupOldPickupHistory();
        // Save pickup notification for parent
        await Get.find<ParentController>().savePickupNotification(
          userId: userId,
          childName: childName,
          message: 'Your child $childName has been picked up from school.',
        );
        await Get.find<ParentController>().cleanupOldPickupNotifications();
      }
      completedPickupsCount.value++;
      resetHistoryAfterDelay();
      await fetchPickupQueueStudents(); // Refresh the queue
      resetPickupStatusAfterDelay(childId); // 60 seconds baad reset
    } catch (e) {
      print('Error marking pickup: $e');
    } finally {
      loadingPickupChildId.value = '';
    }
  }

  // 60 seconds baad completedPickupsCount ko 0 karo
  void resetHistoryAfterDelay() async {
    await Future.delayed(Duration(seconds: 10));
    completedPickupsCount.value = 0;
  }

  // 60 seconds baad parentNotified aur pickedUp ko false karo
  void resetPickupStatusAfterDelay(String childId) async {
    await Future.delayed(Duration(seconds: 10));
    try {
      await FirebaseFirestore.instance.collection("addChild").doc(childId).update({
        "parentNotified": false,
        "pickedUp": false,
      });
      await fetchPickupQueueStudents(); // Refresh the queue
    } catch (e) {
      print('Error resetting pickup status: $e');
    }
  }

  void listenToPickupQueue() {
    _pickupQueueSubscription?.cancel();
    if (assignedClasses.isEmpty) {
      pickupQueueStudents.clear();
      arrivedParentsCount.value = 0;
      return;
    }
    _pickupQueueSubscription = FirebaseFirestore.instance
        .collection('addChild')
        .where('class', whereIn: assignedClasses)
        .where('pickup', isEqualTo: 'Self Pickup')
        .snapshots()
        .listen((querySnapshot) {
      pickupQueueStudents.clear();
      arrivedParentsCount.value = 0;
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        bool parentNotified = data['parentNotified'] ?? false;
        bool pickedUp = data['pickedUp'] ?? false;
        pickupQueueStudents.add({
          'childName': data['childName']?.toString() ?? 'N/A',
          'description': parentNotified ? 'Parent Arrived' : 'Waiting for pickup',
          'parentNotified': parentNotified,
          'pickedUp': pickedUp,
          'childId': doc.id,
        });
        if (parentNotified && !pickedUp) {
          arrivedParentsCount.value++;
        }
      }
    });
  }

  @override
  void onClose() {
    _pickupQueueSubscription?.cancel();
    super.onClose();
  }
}