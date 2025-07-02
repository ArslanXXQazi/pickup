import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/utills/snackbar.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';

class AdminController extends GetxController {
  var isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final selectedRole = RxString('');
  final addUser = ['Teacher', 'Driver', 'Admin'].obs;
  final busses = ['Bus 1', 'Bus 2', 'Bus 3'].obs;
  final grades = [
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10'
  ].obs;

  // Map to store selected bus for each driver
  final RxMap<String, String> selectedBuses = <String, String>{}.obs;

  // Map to store selected classes for each teacher
  final RxMap<String, List<String>> selectedClasses = <String, List<String>>{}.obs;

  // Temporary map to store dialog selections for each teacher
  final RxMap<String, List<String>> tempSelectedClasses = <String, List<String>>{}.obs;

  // Map to store loading state for each driver or teacher
  final RxMap<String, bool> driverLoadingStates = <String, bool>{}.obs;

  // Map to track assigned grades globally
  final RxMap<String, List<String>> assignedGrades = <String, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize assigned grades and buses from Firestore
    fetchAssignedGrades();
    fetchAssignedBuses();
  }

  // Fetch all assigned buses from Firestore
  Future<void> fetchAssignedBuses() async {
    try {
      final driverDocs = await FirebaseFirestore.instance
          .collection('userData')
          .where('role', isEqualTo: 'Driver')
          .get();
      selectedBuses.clear();
      for (var doc in driverDocs.docs) {
        final driverId = doc.id;
        final bus = doc['busses'] ?? '';
        if (bus.isNotEmpty) {
          selectedBuses[driverId] = bus;
        }
      }
    } catch (e) {
      print('Error fetching assigned buses: $e');
      NotificationMessage.show(
        title: 'Error',
        message: 'Failed to load assigned buses: $e',
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Fetch all assigned grades from Firestore
  Future<void> fetchAssignedGrades() async {
    try {
      final teacherDocs = await FirebaseFirestore.instance
          .collection('userData')
          .where('role', isEqualTo: 'Teacher')
          .get();
      assignedGrades.clear();
      for (var doc in teacherDocs.docs) {
        final teacherId = doc.id;
        final classesData = doc['classes'];
        List<String> classes = [];
        if (classesData is String && classesData.isNotEmpty) {
          classes = [classesData];
        } else if (classesData is Iterable) {
          classes = List<String>.from(classesData);
        }
        assignedGrades[teacherId] = classes;
      }
    } catch (e) {
      print('Error fetching assigned grades: $e');
    }
  }

  // Get available grades for a specific teacher
  List<String> getAvailableGrades(String teacherId) {
    final allAssigned = assignedGrades.entries
        .where((entry) => entry.key != teacherId)
        .expand((entry) => entry.value)
        .toSet();
    return grades.where((grade) => !allAssigned.contains(grade)).toList();
  }

  void signUp() async {
    try {
      isLoading.value = true;
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String name = nameController.text.trim();
      String role = selectedRole.value;

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userData(userCredential.user!.uid);
    } catch (e) {
      isLoading.value = false;
      NotificationMessage.show(
        title: "Error",
        message: e.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> userData(String userId) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection("userData").doc(userId).set({
        'userId': userId,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole.value,
        'image': "",
        'busses': "",
        'classes': [],
        'isBlocked': false,
      });
      clear();
      Get.find<UserId>().fetchRoleCounts();
      isLoading.value = false;
      NotificationMessage.show(
        title: "Success",
        message: "User Added Successfully",
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      NotificationMessage.show(
        title: "Error",
        message: e.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
      print("------Error saving user data: ${e.toString()}");
      throw e;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection("userData").doc(userId).delete();
      assignedGrades.remove(userId); // Remove assigned grades for deleted teacher
      Get.find<UserId>().fetchRoleCounts();
      isLoading.value = false;
      NotificationMessage.show(
        title: "Success",
        message: "User Deleted Successfully",
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      NotificationMessage.show(
        title: "Error",
        message: e.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
      print("------Error deleting user: ${e.toString()}");
    }
  }

  Future<void> toggleBlockUser(String userId, bool isCurrentlyBlocked) async {
    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection("userData").doc(userId).update({
        'isBlocked': !isCurrentlyBlocked,
      });
      Get.find<UserId>().fetchRoleCounts();
      isLoading.value = false;
      NotificationMessage.show(
        title: "Success",
        message: isCurrentlyBlocked ? "User Unblocked Successfully" : "User Blocked Successfully",
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      NotificationMessage.show(
        title: "Error",
        message: e.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
      print("------Error toggling block status: ${e.toString()}");
    }
  }

  // Function to assign bus to driver
  Future<void> assignBus(String driverId, String driverName, String busName) async {
    try {
      driverLoadingStates[driverId] = true;
      await FirebaseFirestore.instance.collection('userData').doc(driverId).update({
        'busses': busName,
        'updatedAt': Timestamp.now(),
      });
      selectedBuses[driverId] = busName; // Update local state
      driverLoadingStates[driverId] = false;
      NotificationMessage.show(
        title: 'Success',
        message: '$busName assigned to $driverName',
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      driverLoadingStates[driverId] = false;
      print('Error assigning bus: $e');
      NotificationMessage.show(
        title: 'Error',
        message: 'Failed to assign bus: $e',
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Function to assign multiple classes to teacher
  Future<void> assignClassToTeacher(String teacherId, String teacherName, List<String> classNames) async {
    try {
      driverLoadingStates[teacherId] = true;
      await FirebaseFirestore.instance.collection('userData').doc(teacherId).update({
        'classes': classNames,
        'updatedAt': Timestamp.now(),
      });
      print('Classes assigned successfully to $teacherId');
      assignedGrades[teacherId] = classNames; // Update assigned grades
      driverLoadingStates[teacherId] = false;
      NotificationMessage.show(
        title: 'Success',
        message: '${classNames.join(', ')} assigned to $teacherName',
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      driverLoadingStates[teacherId] = false;
      print('Error assigning classes: $e');
      NotificationMessage.show(
        title: 'Error',
        message: 'Failed to assign classes: $e',
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Function to set selected bus for a driver
  void setSelectedBus(String userId, String bus) {
    selectedBuses[userId] = bus;
  }

  // Function to get selected bus for a driver
  String getSelectedBus(String userId) {
    return selectedBuses[userId] ?? '';
  }

  // Function to set selected classes for a teacher
  void setSelectedClasses(String teacherId, List<String> classes) {
    selectedClasses[teacherId] = classes;
    if (classes.isEmpty) {
      assignedGrades[teacherId] = [];
    } else {
      assignedGrades[teacherId] = classes;
    }
    assignedGrades.refresh();
  }

  // Function to get selected classes for a teacher
  List<String> getSelectedClasses(String teacherId) {
    return selectedClasses[teacherId] ?? [];
  }

  // Function to set temporary dialog selections
  void setTempSelectedClasses(String teacherId, List<String> classes) {
    tempSelectedClasses[teacherId] = classes;
  }

  // Function to get temporary dialog selections
  List<String> getTempSelectedClasses(String teacherId) {
    return tempSelectedClasses[teacherId] ?? getSelectedClasses(teacherId);
  }

  // Function to confirm dialog selections
  void confirmDialogSelections(String teacherId) {
    selectedClasses[teacherId] = List.from(tempSelectedClasses[teacherId] ?? []);
    tempSelectedClasses.remove(teacherId); // Clear temp selections
  }

  // Function to cancel dialog selections
  void cancelDialogSelections(String teacherId) {
    tempSelectedClasses.remove(teacherId); // Clear temp selections
  }

  // Function to get loading state for a driver or teacher
  bool getDriverLoadingState(String userId) {
    return driverLoadingStates[userId] ?? false;
  }

  void clear() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmController.clear();
    selectedRole.value = '';
  }
}