import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pick_up_pal/src/controller/common_widgets/app_logo.dart';
import '../../controller/constant/linkers/linkers.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    /// Get screen dimensions for responsive design
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// App logo with responsive dimensions
          Center(
            child: AppLogo(
              height: screenHeight * 0.14,
              width: screenWidth * 0.3,
              borderRadius: screenHeight * 0.023,
              iconSize: screenWidth * 0.25,
            )
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                .scale(
                begin: Offset(0.5, 0.5),
                end: Offset(1, 1),
                duration: 1000.ms,
                curve: Curves.elasticOut)
                .rotate(
                begin: -0.1,
                end: 0,
                duration: 800.ms,
                curve: Curves.easeOut)
                .shake(
                duration: 600.ms,
                delay: 1000.ms,
                hz: 4,
                offset: Offset(2, 2)), // Logo animation// Logo animation
          ),
          SizedBox(height: screenHeight * 0.02),
          /// Welcome text
          GreenText(
            text: "Welcome to",
            fontSize: 22, // Font size unchanged
            fontWeight: FontWeight.w700,
          )
              .animate()
              .scale(
              begin: Offset(0.8, 0.8),
              end: Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack)
              .fadeIn(duration: 500.ms, delay: 200.ms), // Welcome text animation
          /// App title
          GreenText(
            text: "PickUpPal",
            fontSize: 35, // Font size unchanged
            fontWeight: FontWeight.w700,
          )
              .animate()
              .scale(
              begin: Offset(0.8, 0.8),
              end: Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack)
              .fadeIn(duration: 500.ms, delay: 400.ms), // Title animation
          SizedBox(height: screenHeight * 0.01),
          /// Description text
          GreenText(
            text: "Your smart, safe, and simple\nschool pickup solution",
            fontWeight: FontWeight.w400,
            fontSize: 16, // Font size unchanged
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideX(
              begin: -0.2,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOut), // Description animation
          SizedBox(height: screenHeight * 0.02),
          /// Sign Up button with responsive width
          YellowButton(
            onTap: () {
              Get.toNamed(AppRoutes.signUpView);
            },
            text: "Sign Up",
            width: screenWidth * 0.6,
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
    begin: Offset(1.0, 1.0),
    end: Offset(1.05, 1.05),
    duration: 300.ms,
    curve: Curves.easeOutBack), // Sign Up button animation
          SizedBox(height: screenHeight * 0.02),
          /// Login button with responsive width
          YellowButton(
            onTap: () {
              Get.toNamed(AppRoutes.loginView);
            },
            text: "Login",
            width: screenWidth * 0.6,
            color: Colors.transparent,
            borderColor: AppColors.darkBlue,
          )
              .animate()
              .scale(
              begin: Offset(0.8, 0.8),
              end: Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack)
              .fadeIn(duration: 500.ms, delay: 1000.ms), // Login button animation
        ],
      ),
    );
  }
}