import 'package:flutter/material.dart';
import 'package:pick_up_pal/src/controller/constant/app_images/app_images.dart';

class ProfileContainer extends StatelessWidget {
  double? radius;
  Color? color;
  VoidCallback? ontap;
   ProfileContainer({super.key,
     this.radius,
     this.ontap,
     this.color});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return  GestureDetector(
      onTap: ontap,
      child: CircleAvatar(
        radius: radius ?? screenHeight * 0.035,
        backgroundColor: color ?? Colors.blue.shade200,
        backgroundImage:  AssetImage(AppImages.boy),
      ),
    );
  }
}
