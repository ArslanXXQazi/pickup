import 'package:flutter/material.dart';
import 'package:pick_up_pal/src/controller/common_widgets/text_widget.dart';
import 'package:pick_up_pal/src/controller/constant/app_colors/app_colors.dart';

class HistoryNotificationWidget extends StatelessWidget {
  String title;
  String description;
  IconData? icon;
  Color? backColor;
  Color? borderColor;

  HistoryNotificationWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.backColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenHeight * 0.02),
      decoration: BoxDecoration(
        color: backColor ?? Colors.white,
        border: Border.all(color: borderColor ?? Colors.transparent),
        borderRadius: BorderRadius.circular(screenHeight * 0.025),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.darkBlue),
                SizedBox(width: screenWidth * 0.02),
              ],
              GreenText(
                text: title,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                textColor: Colors.black,
                textAlign: TextAlign.left,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          GreenText(
            text: description,
            fontWeight: FontWeight.w500,
            textColor: Colors.black,
            fontSize: 15,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}