import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:async';

class UserId extends GetxController {
  var userId = ''.obs;
  var role = ''.obs;
  var childNames = <String>[].obs;
  var classNos = <String>[].obs;
  var pickup = <String>[].obs;
  var buses = <String>[].obs;
  var childIds = <String>[].obs;
  var userName = ''.obs; // Added
  var userEmail = ''.obs; // Added
  var parentCount = 0.obs; // Added for Parent count
  var driverCount = 0.obs; // Added for Driver count
  var teacherCount = 0.obs; // Added for Teacher count
  var childStatusList = <Map<String, dynamic>>[].obs;
  var childBuses = <String>[].obs; // For children buses only
  StreamSubscription? _childStatusSubscription;

  String get userRole => role.value; // Getter for userRole

  Future<void> getUserIdAndRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId.value = user.uid;
        var userDoc = await FirebaseFirestore.instance
            .collection('userData')
            .doc(userId.value)
            .get();
        if (userDoc.exists) {
          role.value = userDoc['role'] ?? '';
          userName.value = userDoc['name'] ?? '';
          userEmail.value = userDoc['email'] ?? '';
          buses.value = [userDoc['busses'] ?? '']; // Fetch bus
        }
      }
    } catch (e) {
      print('Error fetching user ID and role: $e');
    }
  }

  Future<void> getChildData() async {
    print('getChildData called');
    print('childNames before clear: \\${childNames.length}');
    childNames.clear();
    classNos.clear();
    pickup.clear();
    childBuses.clear(); // Use this for children
    childIds.clear();

    String userIdValue = userId.value;
    if (userIdValue.isNotEmpty) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('addChild')
          .where('userId', isEqualTo: userIdValue)
          .get();

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        childNames.add(data['childName'] ?? 'N/A');
        classNos.add(data['class'] ?? 'N/A');
        pickup.add(data['pickup'] ?? 'N/A');
        childBuses.add(data['bus'] ?? 'N/A'); // Use childBuses
        childIds.add(doc.id);
      }
      print('Fetched childNames: \\${childNames}');
    }
    print('childNames after fetch: \\${childNames.length}');
  }

  Future<void> fetchRoleCounts() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('userData')
          .get();
      parentCount.value = 0; // Reset counts
      driverCount.value = 0;
      teacherCount.value = 0;
      for (var doc in snapshot.docs) {
        String role = doc['role'] ?? '';
        if (role == 'Parent') parentCount.value++;
        else if (role == 'Driver') driverCount.value++;
        else if (role == 'Teacher') teacherCount.value++;
      }
      print('Parents: ${parentCount.value}, Drivers: ${driverCount.value}, Teachers: ${teacherCount.value}');
    } catch (e) {
      print('Error fetching role counts: $e');
    }
  }

  void clearData() {
    userId.value = '';
    role.value = '';
    childNames.clear();
    classNos.clear();
    pickup.clear();
    buses.clear();
    childIds.clear();
    userName.value = '';
    userEmail.value = '';
    parentCount.value = 0;
    driverCount.value = 0;
    teacherCount.value = 0;
  }

  void getChildStatusStream() {
    String userIdValue = userId.value;
    _childStatusSubscription?.cancel();
    if (userIdValue.isNotEmpty) {
      _childStatusSubscription = FirebaseFirestore.instance
          .collection('addChild')
          .where('userId', isEqualTo: userIdValue)
          .snapshots()
          .listen((querySnapshot) {
        childStatusList.clear();
        for (var doc in querySnapshot.docs) {
          var data = doc.data();
          childStatusList.add({
            'childId': doc.id,
            'parentNotified': data['parentNotified'] ?? false,
            'pickedUp': data['pickedUp'] ?? false,
            'parentConfirmedPickup': data['parentConfirmedPickup'] ?? false,
          });
        }
      });
    }
  }

  @override
  void onClose() {
    _childStatusSubscription?.cancel();
    super.onClose();
  }
}