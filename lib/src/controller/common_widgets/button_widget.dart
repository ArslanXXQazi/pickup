import 'package:flutter/material.dart';
import 'package:pick_up_pal/src/controller/common_widgets/text_widget.dart';
import 'package:pick_up_pal/src/controller/constant/app_colors/app_colors.dart';

class YellowButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? borderRadius;
  final String? image;
  final Color? color;
  final Color borderColor;
  final Color textColor;
  final FontWeight fontWeight;

  YellowButton({
    super.key,
    this.onTap,
    required this.text,
    this.height,
    this.width,
    this.fontSize,
    this.color,
    this.borderColor = Colors.white,
    this.textColor = Colors.black,
    this.fontWeight = FontWeight.w500,
    this.image,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 60,
        decoration: BoxDecoration(
          color: color ?? AppColors.yellowColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(borderRadius ?? 50),
        ),
        child: Center(
          child: image != null
              ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (image != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ImageIcon(AssetImage(image!), color: AppColors.darkBlue),
                ),
              Expanded(
                child: GreenText(
                  text: text,
                  textColor: textColor ?? AppColors.darkBlue,
                  fontSize: fontSize ?? 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.arrow_forward_ios_outlined, size: 20, color: Colors.blue),
              SizedBox(width: 10),
            ],
          )
              : GreenText(
            text: text,
            textColor: textColor ?? AppColors.darkBlue,
            fontSize: fontSize ?? 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}