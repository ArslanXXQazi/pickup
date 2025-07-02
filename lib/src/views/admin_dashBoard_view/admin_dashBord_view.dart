import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/common_widgets/custom_dialog_box.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/assign_bus/assign_bus_view.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';

class AdminDashbordView extends StatelessWidget {
  AdminDashbordView({super.key});

  final AuthController authController = Get.put(AuthController());
  final UserId userIdController = Get.find<UserId>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Call fetchRoleCounts when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userIdController.fetchRoleCounts();
    });

    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
              left: screenWidth * .025,
              right: screenWidth * .025,
              top: screenHeight * .06),
          child: SingleChildScrollView(
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
                    ProfileContainer(
                      ontap: (){
                        Get.toNamed(AppRoutes.driverProfileView);
                      },
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                GreenText(
                  text: "Admin Dashboard",
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: YellowButton(
                        onTap: () {
                          Get.toNamed(AppRoutes.assignBussesView);
                        },
                        text: "Assign Pickup",
                        borderRadius: 15,
                        borderColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(width: screenWidth * .02),
                    Expanded(
                      child: YellowButton(
                        onTap: () {
                          Get.toNamed(AppRoutes.assignClassesView);
                        },
                        text: "Assign Classes",
                        borderRadius: 15,
                        borderColor: Colors.transparent,
                        color: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                YellowButton(
                      onTap: (){
                        Get.toNamed(AppRoutes.viewAllParents);
                      },
                      text: "Parents Details",
                      borderRadius: 15,
                      borderColor: Colors.transparent,
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                     SizedBox(height: screenHeight * 0.02),
                YellowButton(
                      onTap: (){
                        Get.toNamed(AppRoutes.allChildDetail);
                      },
                      text: "Student Details",
                      borderRadius: 15,
                      borderColor: Colors.transparent,
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                SizedBox(height: screenHeight * 0.02),
                Column(
                  children: [
                    // PickupOverviewWidget(pickupScheduled: "8", pickupCompleted: "3"),
                    // SizedBox(height: screenHeight * 0.02),
                    Obx(() => UsersWidget(
                      parents: userIdController.parentCount.value.toString(),
                      driver: userIdController.driverCount.value.toString(),
                      teachers: userIdController.teacherCount.value.toString(),
                    )),
                  ],
                ),
                // Commented code added back as-is
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //   // Expanded(
                //   //     child: ),
                //   SizedBox(width: screenWidth*.025),
                //   // Expanded(
                //   //   flex: 45,
                //   //     child: Column(children: [
                //   //       YellowButton(
                //   //           onTap: (){
                //   //             Get.toNamed(AppRoutes.assignBussesView);
                //   //           },
                //   //           text: "Assign Pickup",
                //   //           borderRadius: 15,
                //   //           borderColor: Colors.transparent,
                //   //       ),
                //   //       SizedBox(height: screenHeight * 0.02),
                //   //       YellowButton(
                //   //           onTap: (){
                //   //             Get.toNamed(AppRoutes.assignClassesView);
                //   //           },
                //   //           text: "Assign Classes",
                //   //           borderRadius: 15,
                //   //           borderColor: Colors.transparent,
                //   //           color: Colors.blue,
                //   //           textColor: Colors.white,
                //   //       ),
                //   //       SizedBox(height: screenHeight * 0.02),
                //   //       NotificationWidget(
                //   //           title: "Today's\nActivity",
                //   //           message: "Student 3 Dropped off at 2:34 pm",
                //   //           message2: "New pickup assigned for student at 1:34 pm",
                //   //       ),
                //   //       SizedBox(height: screenHeight * 0.015),
                //   //       YellowButton(
                //   //         onTap: (){},
                //   //         text: "View All",
                //   //         borderRadius: 15,
                //   //         borderColor: Colors.transparent,
                //   //         color: Colors.blue,
                //   //         textColor: Colors.white,
                //   //       ),
                //   //     ],)),
                //   ],),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * .02, vertical: screenHeight * .025),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreenText(
                        text: "Management",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          // Commented code for Add User button added back as-is
                          // Expanded(child:  YellowButton(
                          //   onTap: (){
                          //     Get.toNamed(AppRoutes.addUsersView);
                          //   },
                          //   text: "Add User",
                          //   borderColor: Colors.transparent,
                          //   borderRadius: 15,
                          //   color: Colors.blue,
                          //   textColor: Colors.white,
                          // )),
                          // SizedBox(width: screenWidth*.03),
                          Expanded(
                            child: YellowButton(
                              onTap: () {
                                Get.toNamed(AppRoutes.manageUserView);
                              },
                              text: "Manage Users",
                              borderColor: Colors.transparent,
                              borderRadius: 15,
                              color: Colors.blue,
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                GreenText(
                  text: "PickUpPal",
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}