import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/constant/linkers/linkers.dart';

class BusDetailsWidget extends StatelessWidget {
  final int busNo;
  final VoidCallback onTap;

  BusDetailsWidget({
    super.key,
    required this.onTap,
    required this.busNo,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025, horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          ///===========>> Bus icon container with animated bus
          Container(
            height: screenHeight * 0.075,
            width: screenHeight * 0.075,
            decoration: BoxDecoration(
              color: AppColors.yellowColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.darkBlue, width: 2),
            ),
            child: Center(
              child: ImageIcon(
                AssetImage(AppImages.bus),
                color: AppColors.darkBlue,
                size: screenWidth * 0.12,
              )
                  .animate()
                  .slideX(
                  begin: -1.0,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutCubic) // Slide-in from left
                  .scale(
                  begin: Offset(0.7, 0.7),
                  end: Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.easeOut) // Zoom-in for depth
                  .then()
                  .shake(
                  duration: 300.ms,
                  hz: 2, // Reduced frequency for smoother shake
                  offset: Offset(1, 0), // Smaller offset for subtle effect
                  curve: Curves.easeOut), // Subtle shake for stopping effect
            ),
          ),
          SizedBox(width: screenWidth * 0.025),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreenText(
                text: "Bus No. $busNo",
                fontSize: screenHeight * 0.025, // Adjusted font size
                fontWeight: FontWeight.w700,
              ),
              GreenText(
                text: "Bus No. $busNo",
                fontSize: screenHeight * 0.018, // Adjusted font size
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          Spacer(),
          Expanded(
            child: YellowButton(
              onTap: onTap,
              text: "Track Bus",
              height: screenHeight * 0.055,
              borderColor: Colors.transparent,
              borderRadius: 10,
              color: AppColors.lightBlue,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}