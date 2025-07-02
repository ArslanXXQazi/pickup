import 'package:get/get.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import '../../../controller/constant/linkers/linkers.dart';
import 'package:flutter/material.dart';
import '../parent_controller.dart';
import '../../../utills/app_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAllChild extends StatelessWidget {
  const ViewAllChild({super.key});

  @override
  Widget build(BuildContext context) {
    final UserId userIdController = Get.find<UserId>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        title: GreenText(
          text: "All Children",
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
           color: Colors.blue.shade100,
          // gradient: LinearGradient(
          //   colors: [Colors.white, Colors.blue.shade200],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03,vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  int minLength = [
                    userIdController.childNames.length,
                    userIdController.childIds.length,
                    userIdController.pickup.length,
                    userIdController.buses.length,
                    userIdController.classNos.length,
                  ].reduce((a, b) => a < b ? a : b);
                  if (minLength == 0) {
                    return Center(
                      child: GreenText(
                        text: "No children added yet",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: minLength,
                    itemBuilder: (context, index) {
                      if (index >= userIdController.childNames.length ||
                          index >= userIdController.childIds.length ||
                          index >= userIdController.pickup.length ||
                          index >= userIdController.buses.length ||
                          index >= userIdController.classNos.length) {
                        return SizedBox();
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                            horizontal: screenWidth * 0.015,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(screenHeight * 0.02),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  ProfileContainer(),
                                  SizedBox(width: screenWidth * 0.03),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GreenText(
                                        text: userIdController.childNames[index],
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      GreenText(
                                        text: "Grade ${userIdController.classNos[index]}",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Expanded(
                                    child: YellowButton(
                                      onTap: () {},
                                      text: "At school",
                                      borderRadius: 10,
                                      height: 40,
                                      fontSize: 12,
                                      color: Colors.blue.shade50,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Obx(() {
                                if (index >= userIdController.pickup.length) return SizedBox();
                                if (userIdController.pickup[index] == "Self Pickup") {
                                  ParentController parentController = Get.find<ParentController>();
                                  return parentController.childLoading[userIdController.childIds[index]] == true
                                      ? AppLoader2()
                                      : YellowButton(
                                          onTap: () {
                                            String childId = userIdController.childIds[index];
                                            parentController.notifySchool(childId);
                                          },
                                          text: "I've Arrived - Notify School",
                                          borderRadius: 20,
                                        );
                                } else {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GreenText(
                                        text: "Driver will pick up: ${userIdController.childNames[index]}",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      Divider(),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 70,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                GreenText(
                                                  text:
                                                  "Assigned Bus : ${userIdController.buses[index] == 'N/A' ? 'None' : userIdController.buses[index]}",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 30,
                                            child: YellowButton(
                                              onTap: () async {
                                                String childId = userIdController.childIds[index];
                                                var doc = await FirebaseFirestore.instance.collection('addChild').doc(childId).get();
                                                if (doc.exists && doc.data()!.containsKey('assignedDriverId') && (doc.data()!['assignedDriverId'] ?? '').toString().isNotEmpty) {
                                                  String assignedDriverId = doc.data()!['assignedDriverId'];
                                                  Get.toNamed(AppRoutes.trackPickup, arguments: {'childId': childId, 'assignedDriverId': assignedDriverId});
                                                } else {
                                                  Get.snackbar('Error', 'No driver assigned to this child!', backgroundColor: Colors.red, colorText: Colors.white);
                                                }
                                              },
                                              text: "Track Pickup",
                                              borderRadius: 10,
                                              fontSize: 12,
                                              height: 45,
                                              color: Colors.blue,
                                              textColor: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}