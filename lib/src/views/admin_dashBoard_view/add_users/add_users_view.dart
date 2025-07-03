import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_controller/admin_controller.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';

import '../../../controller/common_widgets/text_field_widget.dart';
import '../../../controller/constant/linkers/linkers.dart';

class AddUserView extends StatelessWidget {
  AddUserView({super.key});

  final AdminController adminController = Get.put(AdminController());

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
                      controller: adminController.nameController,
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
                      controller: adminController.emailController,
                      hintText: "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter an email";
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    /// Password text field
                    Obx(() => TextFieldWidget(
                      controller: adminController.passwordController,
                      hintText: "Password",
                      isPassword: !adminController.isPasswordVisible.value,
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
                          adminController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.darkBlue,
                        ),
                        onPressed: adminController.togglePasswordVisibility,
                      ),
                    )),
                    SizedBox(height: screenHeight * 0.02),
                    /// Confirm Password text field
                    Obx(() => TextFieldWidget(
                      controller: adminController.confirmController,
                      hintText: "Confirm Password",
                      isPassword: !adminController.isConfirmPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter confirm password";
                        }
                        if (value != adminController.passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          adminController.isConfirmPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.darkBlue,
                        ),
                        onPressed: adminController.toggleConfirmPasswordVisibility,
                      ),
                    )),
                    SizedBox(height: screenHeight * 0.02),
                    /// Role text field with dropdown icon
                    Obx(() => RoleTextFieldWidget(
                      role: adminController.addUser,
                      selectedRole:
                      adminController.selectedRole.value.isEmpty
                          ? null
                          : adminController.selectedRole.value,
                      onChanged: (value) {
                        adminController.selectedRole.value = value ?? '';
                      },
                    )),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
              /// Sign Up button
              Obx(() => adminController.isLoading.value
                  ? AppLoader2()
                  : YellowButton(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    adminController.signUp();
                  }
                },
                text: "Add User",
                color: AppColors.darkBlue,
                borderColor: Colors.transparent,
                borderRadius: 10,
                textColor: Colors.white,
                fontSize: 20,
              )),
            ],
          ),
        ),
      ),
    );
  }
}