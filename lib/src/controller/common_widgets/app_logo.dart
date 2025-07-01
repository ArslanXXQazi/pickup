import 'package:flutter/material.dart';

import '../constant/linkers/linkers.dart';

class AppLogo extends StatelessWidget {

  final double? height;
  final double? width;
  final double? iconSize;
  final double? borderRadius;
  final Duration? mSec;


  const AppLogo({super.key,
    this.height,
    this.width,
    this.mSec,
    this.iconSize,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return  Container(
      height: height ?? screenHeight * 0.15,
      width: width ??screenWidth * 0.35,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(borderRadius??25),
      ),
      child: Center(
        child: Image(image: AssetImage(AppImages.logo)),
      ),
    );
  }
}
