import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    /// Get screen dimensions for responsive design
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.blue.shade300,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * .03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GreenText(
              text: "Enter your email address, we will send you a link to reset your password.",
              textAlign: TextAlign.center,
              textColor: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            SizedBox(height: screenHeight * .02),
            Form(
              key: formKey,
              child: TextFieldWidget(
                controller: authController.forgotController,
                hintText: "Email",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an email";
                  }
                  // Simpler and more reliable email RegEx
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: screenHeight * .02),
            Obx(() => authController.isLoading.value
                ? AppLoader2()
                : YellowButton(
              onTap: () {
                if (formKey.currentState!.validate()) {
                  authController.forgotPassword();
                }
              },
              text: "Send Link",
              color: AppColors.yellowColor,
              borderColor: Colors.transparent,
              borderRadius: 10,
              fontSize: 18,
            )),
          ],
        ),
      ),
    );
  }
}