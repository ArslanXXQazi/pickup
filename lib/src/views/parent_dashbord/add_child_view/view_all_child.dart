import 'package:get/get.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import '../../../controller/constant/linkers/linkers.dart';
import 'package:flutter/material.dart';
import '../parent_controller.dart';
import '../../../utills/app_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAllChild extends StatelessWidget with WidgetsBindingObserver {
  const ViewAllChild({super.key});

  @override
  Widget build(BuildContext context) {
    final UserId userIdController = Get.find<UserId>();
    userIdController.getChildStatusStream();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Add observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);

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
                  print('ViewAllChild: childNames = \\${userIdController.childNames}');
                  int minLength = [
                    userIdController.childNames.length,
                    userIdController.childIds.length,
                    userIdController.pickup.length,
                    userIdController.childBuses.length,
                    userIdController.classNos.length,
                  ].reduce((a, b) => a < b ? a : b);
                  print('ViewAllChild: minLength = \\${minLength}, childNames = \\${userIdController.childNames}, childIds = \\${userIdController.childIds}, pickup = \\${userIdController.pickup}, childBuses = \\${userIdController.childBuses}, classNos = \\${userIdController.classNos}');
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
                      String childId = userIdController.childIds[index];
                      ParentController parentController = Get.find<ParentController>();
                      parentController.checkAndResetStatus(childId);
                      if (index >= userIdController.childNames.length ||
                          index >= userIdController.childIds.length ||
                          index >= userIdController.pickup.length ||
                          index >= userIdController.childBuses.length ||
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
                                        text: "${userIdController.classNos[index]}",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Expanded(
                                    child: Obx(() {
                                      print('UI: childStatusList = \\${userIdController.childStatusList}');
                                      var status = userIdController.childStatusList.firstWhereOrNull((e) => e['childId'] == childId);
                                      String statusField = status?['status'] ?? 'At school';
                                      String statusText = "At school";
                                      if (userIdController.pickup[index] == "Self Pickup") {
                                        if (status?['parentConfirmedPickup'] == true) statusText = "Picked Up";
                                        else statusText = "At school";
                                      } else {
                                        if (statusField == 'Onboard') statusText = "Onboard";
                                        else if (statusField == 'Dropped Off') statusText = "Dropped Off";
                                        else statusText = "At school";
                                      }
                                      return YellowButton(
                                        onTap: () {},
                                        text: statusText,
                                        borderRadius: 10,
                                        height: 40,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue.shade50,
                                        width: screenWidth * 0.28 > 120 ? screenWidth * 0.28 : 120,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Obx(() {
                                if (index >= userIdController.pickup.length) return SizedBox();
                                if (userIdController.pickup[index] == "Self Pickup") {
                                  var status = userIdController.childStatusList.firstWhereOrNull((e) => e['childId'] == childId);
                                  bool parentNotified = status?['parentNotified'] ?? false;
                                  bool pickedUp = status?['pickedUp'] ?? false;
                                  bool parentConfirmedPickup = status?['parentConfirmedPickup'] ?? false;
                                  if (parentController.childLoading[childId] == true) {
                                    return AppLoader2();
                                  }
                                  if (pickedUp && !parentConfirmedPickup && parentController.confirmLoading[childId] == true) {
                                    return YellowButton(
                                      onTap: null,
                                      text: "Confirm Pickup...",
                                      borderRadius: 20,
                                      color: Colors.green,
                                      textColor: Colors.white,
                                    );
                                  }
                                  String btnText = "I've Arrived - Notify School";
                                  Color btnColor = AppColors.yellowColor;
                                  bool btnEnabled = true;
                                  Color btnTextColor = Colors.black;
                                  if (parentNotified && !pickedUp) {
                                    btnText = "Waiting";
                                    btnColor = Colors.grey.shade400;
                                    btnEnabled = false;
                                  } else if (pickedUp && !parentConfirmedPickup) {
                                    btnText = "Confirm Pickup";
                                    btnColor = Colors.green;
                                    btnEnabled = true;
                                    btnTextColor = Colors.white;
                                  } else if (parentConfirmedPickup) {
                                    btnText = "Picked Up";
                                    btnColor = Colors.green;
                                    btnEnabled = false;
                                  }
                                  return YellowButton(
                                    onTap: btnEnabled ? () {
                                      if (pickedUp && !parentConfirmedPickup) {
                                        parentController.confirmParentPickup(childId);
                                      } else {
                                        parentController.notifySchool(childId);
                                      }
                                    } : null,
                                    text: btnText,
                                    borderRadius: 20,
                                    color: btnColor,
                                    textColor: btnTextColor,
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
                                                  "Assigned Bus : ${userIdController.childBuses[index] == 'N/A' ? 'None' : userIdController.childBuses[index]}",
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final UserId userIdController = Get.find<UserId>();
      userIdController.getChildData();
      userIdController.getChildStatusStream();
    }
  }
}