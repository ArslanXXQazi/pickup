import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';
import '../../controller/constant/linkers/linkers.dart';

class SignUpView extends StatelessWidget {
  SignUpView({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    /// Get screen dimensions for responsive design
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      /// Set background color for the entire screen
      backgroundColor: Colors.blue.shade300,
      body: Padding(
        /// Responsive padding using media query
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.035, vertical: screenHeight * 0.06),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Logo container with tracking icon
              AppLogo(
                height: screenHeight * 0.15,
                width: screenWidth * 0.35,
                iconSize: screenWidth * .25,
              ),
              SizedBox(height: screenHeight * 0.01),
              /// App title
              GreenText(
                text: "PickUpPal",
                fontSize: 35,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: screenHeight * 0.02),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    /// Full Name text field
                    TextFieldWidget(
                      controller: authController.nameController,
                      hintText: "Full Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    /// Email text field
                    TextFieldWidget(
                      controller: authController.emailController,
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
                    SizedBox(height: screenHeight * 0.02),
                    /// Password text field
                    Obx(() => TextFieldWidget(
                      controller: authController.passwordController,
                      hintText: "Password",
                      isPassword: !authController.isPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a password";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: authController.togglePasswordVisibility,
                      ),
                    )),
                    SizedBox(height: screenHeight * 0.02),
                    /// Confirm Password text field
                    Obx(() => TextFieldWidget(
                      controller: authController.confirmController,
                      hintText: "Confirm Password",
                      isPassword: !authController.isConfirmPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter confirm password";
                        }
                        if (value != authController.passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isConfirmPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: authController.toggleConfirmPasswordVisibility,
                      ),
                    )),
                    SizedBox(height: screenHeight * 0.02),
                    /// Role text field with dropdown icon
                    Obx(() => RoleTextFieldWidget(
                      role: authController.roles,
                      selectedRole:
                      authController.selectedRole.value.isEmpty
                          ? null
                          : authController.selectedRole.value,
                      onChanged: (value) {
                        authController.selectedRole.value = value ?? '';
                      },
                    )),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
              /// Sign Up button
              Obx(() => authController.isLoading.value
                  ? AppLoader2()
                  : YellowButton(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    authController.signUp();
                  }
                },
                text: "Sign Up",
                color: AppColors.darkBlue,
                borderColor: Colors.transparent,
                borderRadius: 10,
                textColor: Colors.white,
                fontSize: 20,
              )),
              SizedBox(height: screenHeight * 0.02),
              /// Login prompt row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GreenText(
                    text: "Already have an account?",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  GreenText(
                    onTap: () {
                      Get.toNamed(AppRoutes.loginView);
                    },
                    text: "  Login",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}