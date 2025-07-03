import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/utills/snackbar.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_controller/admin_controller.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/parent_controller.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController forgotController = TextEditingController();

  final UserId userIdController = Get.find<UserId>();
  final AdminController adminController = Get.put(AdminController());
  final ParentController parentController = Get.put(ParentController());

  final selectedRole = RxString('');
  final roles = ['Parent'].obs;

  // Profile state for GetX UI
  var isProfileLoading = true.obs;
  final profileNameController = TextEditingController();
  final profileEmailController = TextEditingController();
  final profileAddressController = TextEditingController();
  final profilePhoneController = TextEditingController();

  // Password visibility for login/signup
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void initProfileFields() async {
    isProfileLoading.value = true;
    await loadProfileData(
      nameController: profileNameController,
      emailController: profileEmailController,
      addressController: profileAddressController,
      phoneController: profilePhoneController,
    );
    isProfileLoading.value = false;
  }

  void logIn() async {
    try {
      isLoading.value = true;
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      await userIdController.getUserIdAndRole();

      String role = userIdController.userRole; // Changed from userRole.value
      print('------Role after login: $role');

      if (role == "Admin") {
        Get.offAllNamed(AppRoutes.adminView);
      } else if (role == "Parent") {
        Get.offAllNamed(AppRoutes.parentDashBord);
      } else if (role == "Teacher") {
        Get.offAllNamed(AppRoutes.teacherDashBord);
      } else if (role == "Driver") {
        Get.offAllNamed(AppRoutes.driverDashBordView);
      } else {
        throw Exception("Invalid or no role found for this user");
      }

      clear();
      NotificationMessage.show(
        title: "Success",
        message: "Logged in successfully",
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      NotificationMessage.show(
        title: "Error",
        message: error.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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

      await userIdController.getUserIdAndRole();

      if (userIdController.userId.value.isNotEmpty) {
        await userData();
        Get.toNamed(AppRoutes.loginView);
        clear();
        NotificationMessage.show(
          title: "Success",
          message: "Account Created Successfully",
          backGroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception("User ID not found after signup");
      }
    } catch (error) {
      NotificationMessage.show(
        title: "Error",
        message: error.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> userData() async {
    try {
      String userId = userIdController.userId.value;
      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance.collection("userData").doc(userId).set({
          'userId': userId,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': selectedRole.value,
          'image': "",
          'busses': "",
          'classes': ""
        });
        print("------User data saved successfully for userId: $userId");
      } else {
        print("------Error: User ID is empty, cannot save data");
        throw Exception("User ID is empty");
      }
    } catch (e) {
      print("------Error saving user data: ${e.toString()}");
      throw e;
    }
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      final userIdController = Get.find<UserId>();
      final parentController = Get.isRegistered<ParentController>()
          ? Get.find<ParentController>()
          : null;
      final adminController = Get.isRegistered<AdminController>()
          ? Get.find<AdminController>()
          : null;

      userIdController.userId.value = "";
      userIdController.childNames.clear();
      userIdController.classNos.clear();
      userIdController.pickup.clear();
      userIdController.buses.clear();
      userIdController.parentCount.value = 0;
      userIdController.driverCount.value = 0;
      userIdController.teacherCount.value = 0;

      if (parentController != null) {
        parentController.clear();
        parentController.selectedGender.value = '';
        parentController.selectedPickup.value = '';
        parentController.selectedBus.value = '';
        parentController.selectedGrade.clear();
      }

      if (adminController != null) {
        adminController.clear();
        adminController.selectedBuses.clear();
        adminController.selectedClasses.clear();
        adminController.tempSelectedClasses.clear();
        adminController.driverLoadingStates.clear();
        adminController.assignedGrades.clear();
      }

      Get.offAllNamed(AppRoutes.loginView);

      NotificationMessage.show(
        title: "Success",
        message: "Logout Successfully",
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
    }
  }

  void clear() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmController.clear();
  }

  /// Load profile data for the logged-in user and set controllers
  Future<void> loadProfileData({
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController addressController,
    required TextEditingController phoneController,
  }) async {
    await userIdController.getUserIdAndRole();
    final userId = userIdController.userId.value;
    if (userId.isNotEmpty) {
      final doc = await FirebaseFirestore.instance.collection('userData').doc(userId).get();
      final data = doc.data() ?? {};
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      addressController.text = data['address'] ?? '';
      phoneController.text = data['phone'] ?? '';
    }
  }

  /// Save profile data for the logged-in user from controllers
  Future<void> saveProfile({
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController addressController,
    required TextEditingController phoneController,
  }) async {
    isLoading.value = true;
    final userId = userIdController.userId.value;
    if (userId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('userData').doc(userId).update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
      });
      await userIdController.getUserIdAndRole();
      NotificationMessage.show(
        title: "Success",
        message: "Profile updated successfully",
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
    isLoading.value = false;
  }

  /// Send password reset email
  Future<void> forgotPassword() async {
    try {
      isLoading.value = true;
      String email = forgotController.text.trim();

      if (email.isEmpty) {
        throw Exception("Please enter an email address");
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      NotificationMessage.show(
        title: "Success",
        message: "Password reset link sent to your email",
        backGroundColor: Colors.green,
        textColor: Colors.white,
      );

      forgotController.clear();
      Get.toNamed(AppRoutes.loginView);
    } catch (error) {
      NotificationMessage.show(
        title: "Error",
        message: error.toString(),
        backGroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

}