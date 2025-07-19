import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/parent_controller.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadCompletedPickupsCount();
    fetchTeacherData();
    ever(assignedClasses, (_) {
      fetchPickupQueueStudents();
      listenToPickupQueue();
    });
    listenToPickupQueue();
  }

  Future<void> _loadCompletedPickupsCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('completedPickupsCount') ?? 0;
    String? lastUpdateStr = prefs.getString('historyResetAt');
    DateTime? lastUpdate = lastUpdateStr != null ? DateTime.tryParse(lastUpdateStr) : null;
    if (lastUpdate != null && DateTime.now().isBefore(lastUpdate)) {
      completedPickupsCount.value = count;
    } else {
      completedPickupsCount.value = 0;
    }
  }

  Future<void> _saveCompletedPickupsCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completedPickupsCount', completedPickupsCount.value);
    await prefs.setString('historyResetAt', DateTime.now().add(Duration(minutes: 10)).toIso8601String());
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
      _sortPickupQueueStudents();
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
        "parentConfirmedPickup": false,
      });
      // Fetch childName and userId for history
      var doc = await FirebaseFirestore.instance.collection("addChild").doc(childId).get();
      var data = doc.data();
      if (data != null) {
        String childName = data['childName'] ?? '';
        String userId = data['userId'] ?? '';
        // Yahan se history save karna hata diya hai
        // Save pickup notification for parent
        await Get.find<ParentController>().savePickupNotification(
          userId: userId,
          childName: childName,
          message: 'Your child $childName has been picked up from school.',
        );
        await Get.find<ParentController>().cleanupOldPickupNotifications();
      }
      completedPickupsCount.value++;
      _saveCompletedPickupsCount();
      await fetchPickupQueueStudents(); // Refresh the queue
    } catch (e) {
      print('Error marking pickup: $e');
    } finally {
      loadingPickupChildId.value = '';
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
      _sortPickupQueueStudents();
    });
  }

  // Sort pickupQueueStudents: 1) parentNotified & !pickedUp, 2) !parentNotified & !pickedUp, 3) pickedUp
  void _sortPickupQueueStudents() {
    pickupQueueStudents.sort((a, b) {
      int getOrder(Map<String, dynamic> student) {
        if (student['pickedUp'] == true) return 2; // bottom
        if (student['parentNotified'] == true) return 0; // top
        return 1; // middle
      }
      int orderA = getOrder(a);
      int orderB = getOrder(b);
      if (orderA != orderB) return orderA.compareTo(orderB);
      // Optionally, sort by childName within each group
      return (a['childName'] ?? '').compareTo(b['childName'] ?? '');
    });
  }

  /// Save teacher notification
  Future<void> saveTeacherNotification({
    required String teacherId,
    required String childName,
    required String message,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('teacherNotifications').add({
        'teacherId': teacherId,
        'childName': childName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'forRole': 'teacher',
      });
    } catch (e) {
      print('Error saving teacher notification: $e');
    }
  }

  /// Fetch teacher notifications for the current user (last 1 minute, only for teacher)
  Future<void> fetchTeacherNotifications(String teacherId) async {
    try {
      final oneMinuteAgo = DateTime.now().subtract(Duration(minutes: 1));
      // Delete notifications older than 1 minute
      final oldSnapshot = await FirebaseFirestore.instance
          .collection('teacherNotifications')
          .where('teacherId', isEqualTo: teacherId)
          .where('forRole', isEqualTo: 'teacher')
          .orderBy('timestamp')
          .where('timestamp', isLessThan: oneMinuteAgo.toIso8601String())
          .get();
      for (var doc in oldSnapshot.docs) {
        await doc.reference.delete();
      }
      // Fetch only notifications from the last 1 minute for teacher
      final snapshot = await FirebaseFirestore.instance
          .collection('teacherNotifications')
          .where('teacherId', isEqualTo: teacherId)
          .where('forRole', isEqualTo: 'teacher')
          .orderBy('timestamp', descending: true)
          .where('timestamp', isGreaterThan: oneMinuteAgo.toIso8601String())
          .get();
      // teacherNotificationsList.value = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching teacher notifications: $e');
    }
  }

  @override
  void onClose() {
    _pickupQueueSubscription?.cancel();
    super.onClose();
  }
}