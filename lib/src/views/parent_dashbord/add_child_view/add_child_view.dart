import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/common_widgets/multi_select_widget.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/parent_controller.dart';
import '../../../controller/constant/linkers/linkers.dart';

class AddChildView extends StatelessWidget {
  AddChildView({super.key});
  final ParentController parentController = Get.find<ParentController>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                left: screenWidth * .02,
                right: screenWidth * .02,
                top: screenHeight * .1),
            child: Column(
              children: [
                Row(
                  children: [
                    AppLogo(
                      height: screenHeight * 0.08,
                      width: screenHeight * 0.08,
                      iconSize: screenHeight * 0.06,
                      borderRadius: 15,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    GreenText(
                      text: "PickUpPal",
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                    const Spacer(),
                    ProfileContainer(),
                  ],
                ),
                SizedBox(height: screenHeight * .025),
                ProfileContainer(),
                SizedBox(height: screenHeight * .025),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      /// Full Name text field
                      TextFieldWidget(
                        controller: parentController.nameController,
                        hintText: "Child Name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a name";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      /// School field
                      // TextFieldWidget(
                      //   controller: parentController.schoolController,
                      //   hintText: "School",
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return "Please enter School";
                      //     }
                      //     return null;
                      //   },
                      // ),
                      SizedBox(height: screenHeight * 0.02),
                      /// Grade dropdown
                      MultiSelectGradeWidget(
                        grades: parentController.grades,
                        selectedGrades: parentController.selectedGrade,
                        isSingleSelection: true, // Enable single selection for Parent
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a grade";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      /// Age text field and gender dropdown
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              keyboardType: TextInputType.number,
                              controller: parentController.ageController,
                              hintText: "Age",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter age";
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          /// Gender dropdown
                          Expanded(
                            child: Obx(() => RoleTextFieldWidget(
                              hintText: "Gender",
                              role: parentController.gender,
                              selectedRole: parentController
                                  .selectedGender.value.isEmpty
                                  ? null
                                  : parentController.selectedGender.value,
                              onChanged: (value) {
                                parentController.selectedGender.value =
                                    value ?? '';
                              },
                            )),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      /// Pickup dropdown
                      Obx(() => RoleTextFieldWidget(
                        hintText: "Pickup",
                        role: parentController.pickup,
                        selectedRole: parentController
                            .selectedPickup.value.isEmpty
                            ? null
                            : parentController.selectedPickup.value,
                        onChanged: (value) {
                          parentController.selectedPickup.value = value ?? '';
                          if (value != 'Driver Pickup') {
                            parentController.selectedBus.value = '';
                          }
                        },
                      )),
                      SizedBox(height: screenHeight * 0.02),
                      /// Bus dropdown (only shown if Driver Pickup is selected)
                      Obx(() => parentController.selectedPickup.value == 'Driver Pickup'
                          ? RoleTextFieldWidget(
                        hintText: "Select Bus",
                        role: parentController.buses,
                        selectedRole: parentController
                            .selectedBus.value.isEmpty
                            ? null
                            : parentController.selectedBus.value,
                        onChanged: (value) {
                          parentController.selectedBus.value = value ?? '';
                        },
                      )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * .01),
                Obx(() => parentController.isLoading.value
                    ? AppLoader2()
                    : YellowButton(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      parentController.addChild();
                    }
                  },
                  text: "Add Child",
                  borderColor: Colors.transparent,
                  borderRadius: 10,
                  fontSize: 20,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}