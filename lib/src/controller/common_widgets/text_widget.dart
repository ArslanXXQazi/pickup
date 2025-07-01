import 'package:flutter/material.dart';
import 'package:pick_up_pal/src/controller/constant/app_colors/app_colors.dart';


//===========>>> Utility class for responsive dimensions
class Responsive {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _baseFontSize;

  //===========>>> Initialize with BuildContext
  static void init(BuildContext context) {
    _screenWidth = MediaQuery.sizeOf(context).width;
    _screenHeight = MediaQuery.sizeOf(context).height;
    _baseFontSize = 16; // Base font size for scaling
  }

  //===========>>> Get responsive font size
  static double fontSize(double size) {
    return size *
        (_screenWidth / 375); // Scale based on 375px width (standard mobile)
  }

  //===========>>> Get responsive height
  static double height(double value) {
    return value * (_screenHeight / 750); // Scale based on 750px height
  }

  //===========>>> Get responsive width
  static double width(double value) {
    return value * (_screenWidth / 375); // Scale based on 375px width
  }
}

class GreenText extends StatelessWidget {
  final String? text;
  final VoidCallback? onTap;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final TextAlign? textAlign;

  const GreenText({
    super.key,
    this.text,
    this.onTap,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    //===========>>> Initialize Responsive utility
    Responsive.init(context);

    return InkWell(
      //===========>>> Tappable text container
      onTap: onTap ?? null,
      child: Text(
        //===========>>> Display text or empty string
        text ?? "",
        textAlign: textAlign ?? TextAlign.center,
        style: TextStyle(
          //===========>>> Responsive font size
          fontSize:
          fontSize != null
              ? Responsive.fontSize(fontSize!)
              : Responsive.fontSize(16), // Default font size scaled
          fontWeight: fontWeight ?? FontWeight.w500,
          color: textColor ?? AppColors.darkBlue,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:trauma/src/controller/constant/app_colors/app_colors.dart';
//
// class GreenText extends StatelessWidget {
//   final String? text;
//   final VoidCallback? onTap;
//   final double? fontSize;
//   final FontWeight? fontWeight;
//   final Color? textColor;
//   final TextAlign? textAlign; // New parameter
//
//   const GreenText({
//     super.key,
//     this.text,
//     this.onTap,
//     this.fontSize,
//     this.fontWeight,
//     this.textColor,
//     this.textAlign, // Added to constructor
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap ?? null,
//       child: Text(
//         text ?? "",
//         textAlign: textAlign ??
//             TextAlign.center, // Default to center, override if provided
//         style: TextStyle(
//           fontSize: fontSize ?? 16,
//           fontWeight: fontWeight ?? FontWeight.w500,
//           color: textColor ?? AppColors.darkGreenColor,
//         ),
//       ),
//     );
//   }
// }
