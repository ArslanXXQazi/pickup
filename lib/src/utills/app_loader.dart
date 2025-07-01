import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pick_up_pal/src/controller/constant/app_colors/app_colors.dart';

class AppLoader2 extends StatelessWidget {
  const AppLoader2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: AppColors.yellowColor,
        size: 60,
      ),
    );
  }
}

class Apploader3 extends StatelessWidget {
  const Apploader3({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        color: AppColors.yellowColor,
        size: 80,

      ),
    );
  }
}