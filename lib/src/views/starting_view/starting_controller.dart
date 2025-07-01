import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/routes/app_routes.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartingController extends GetxController {
  final UserId userIdController = Get.find<UserId>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        print('------User is logged in: ${currentUser.uid}');
        await userIdController.getUserIdAndRole();

        String role = userIdController.userRole;
        String email = currentUser.email ?? "";

        print('------Role fetched: $role, Email: $email');

        if (email == "admin@gmail.com") {
          Get.offAllNamed(AppRoutes.adminView);
        } else if (role == "Parent") {
          Get.offAllNamed(AppRoutes.parentDashBord);
        } else if (role == "Teacher") {
          Get.offAllNamed(AppRoutes.teacherDashBord);
        } else if (role == "Driver") {
          Get.offAllNamed(AppRoutes.driverDashBordView);
        } else {
          print('------Invalid or no role found, redirecting to welcome view');
          await Future.delayed(const Duration(seconds: 3));
          Get.offAllNamed(AppRoutes.welcomeView);
        }
      } else {
        print('------No user is logged in, redirecting to welcome view');
        await Future.delayed(const Duration(seconds: 3));
        Get.offAllNamed(AppRoutes.welcomeView);
      }
    } catch (e) {
      print('------Error in navigation: ${e.toString()}');
      await Future.delayed(const Duration(seconds: 3));
      Get.offAllNamed(AppRoutes.welcomeView);
    }
  }

  Future<void> updateDriverLocation(double lat, double lng) async {
    try {
      final userId = userIdController.userId.value;
      if (userId.isNotEmpty) {
        print('Updating Firestore: $lat, $lng');
        await FirebaseFirestore.instance.collection('userData').doc(userId).update({
          'latitude': lat,
          'longitude': lng,
        });
      }
    } catch (e) {
      print('Error updating driver location: $e');
    }
  }
}