import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pick_up_pal/src/controller/common_widgets/app_logo.dart';
import '../../controller/constant/linkers/linkers.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          /// Get screen dimensions for responsive design
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final controller = Get.put(StartingController());

          return Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// App logo with dramatic zoom, rotate, and shake
                AppLogo(
                  height: screenHeight * 0.20,
                  width: screenWidth * 0.4,
                  iconSize: screenWidth * 0.35,
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
                    offset: Offset(2, 2)), // Logo animation
                SizedBox(height: screenHeight * 0.01),
                /// App title with letter-by-letter reveal and glow
                GreenText(
                  text: "PickUpPal",
                  fontSize: 35, // Font size unchanged
                  fontWeight: FontWeight.w700,
                )
                    .animate(
                  onPlay: (controller) =>
                      controller.repeat(reverse: false, period: 2000.ms),
                )
                    .custom(
                  duration: 1200.ms,
                  delay: 800.ms,
                  builder: (context, value, child) {
                    // Split text into characters for individual animation
                    final chars = "PickUpPal".split('');
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: chars.asMap().entries.map((entry) {
                        final index = entry.key;
                        final char = entry.value;
                        final charDelay =
                        Duration(milliseconds: index * 100);
                        return Animate(
                          effects: [
                            FadeEffect(
                              duration: 600.ms,
                              delay: charDelay + 800.ms,
                              curve: Curves.easeOut,
                            ),
                            ScaleEffect(
                              begin: Offset(0.8, 0.8),
                              end: Offset(1, 1),
                              duration: 600.ms,
                              delay: charDelay + 800.ms,
                              curve: Curves.bounceOut,
                            ),
                            ShimmerEffect(
                              duration: 1000.ms,
                              delay: charDelay + 1400.ms,
                              color: Colors.yellow.withOpacity(0.5),
                            ),
                          ],
                          child: Text(
                            char,
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ), // Title animation
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(
              begin: -0.1,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOut); // Background animation
        },
      ),
    );
  }
}