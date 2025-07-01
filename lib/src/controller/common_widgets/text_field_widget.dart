import 'package:flutter/material.dart';
import 'package:pick_up_pal/src/controller/constant/app_colors/app_colors.dart';

import '../constant/app_images/app_images.dart';

class TextFieldWidget extends StatelessWidget {



  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final int? maxLine;
  final Color? textColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? fillColor;
  final bool readOnly;


  const TextFieldWidget({
    Key? key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
    this.maxLength,
    this.maxLine,
    this.textColor,
    this.borderColor,
    this.focusBorderColor,
    this.hintColor,
    this.fillColor,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          readOnly: readOnly,
        //  obscureText: passwordFieldController.isPasswordVisible.value,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          maxLines: maxLine??1,
          style: TextStyle(
            color: textColor ?? AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: hintColor ?? AppColors.darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
            filled: true,
            fillColor: fillColor?? Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor ?? AppColors.darkBlue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor ?? AppColors.darkBlue,width: 2.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: focusBorderColor ?? AppColors.darkBlue,width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.red),
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            errorStyle: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}







class RoleTextFieldWidget extends StatelessWidget {
  final List<String> role;
  final String? selectedRole;
  final ValueChanged<String?>? onChanged;
  final String hintText;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? fillColor;

  const RoleTextFieldWidget({
    Key? key,
    required this.role,
    this.selectedRole,
    this.onChanged,
    this.hintText = 'Select Role',
    this.borderColor,
    this.focusBorderColor,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return DropdownButtonFormField<String>(
      value: selectedRole,
      items: role
          .map((role) => DropdownMenuItem(
        value: role,
        child: Text(role),
      ))
          .toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select a role";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: isPortrait ? screenHeight * 0.015 : screenHeight * 0.025,
        ),
        filled: true,
        fillColor: fillColor ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor ?? AppColors.darkBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: borderColor ?? AppColors.darkBlue, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          BorderSide(color: focusBorderColor ?? AppColors.darkBlue, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}