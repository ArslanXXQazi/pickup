import 'dart:math';
import 'dart:async';
import 'package:pick_up_pal/src/controller/common_widgets/custom_dialog_box.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/parent_controller.dart' show ParentController;
import '../../controller/constant/linkers/linkers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pick_up_pal/src/utills/snackbar.dart';

class ParentDashbord extends StatefulWidget {
  ParentDashbord({super.key});

  @override
  State<ParentDashbord> createState() => _ParentDashbordState();
}

class _ParentDashbordState extends State<ParentDashbord> {
  final UserId userIdController = Get.find<UserId>();
  final AuthController authController = Get.put(AuthController());
  final ParentController parentController = Get.find<ParentController>();

  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  StreamSubscription<QuerySnapshot>? _pickupNotificationSubscription;
  String? _lastNotificationId;

  @override
  void initState() {
    super.initState();
    _loadLastNotificationId();
    userIdController.getUserIdAndRole().then((_) {
      if (userIdController.userId.value.isNotEmpty) {
        userIdController.getChildData();
        _listenToParentNotifications(userIdController.userId.value);
        parentController.fetchPickupNotifications();
        _listenToPickupNotifications(userIdController.userId.value);
      }
    });
  }

  Future<void> _loadLastNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
  }

  void _listenToParentNotifications(String userId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = FirebaseFirestore.instance
        .collection('pickupNotifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) async {
      final prefs = await SharedPreferences.getInstance();
      List<String> seenIds = prefs.getStringList('seenParentNotificationIds') ?? [];
      bool updated = false;
      for (var doc in snapshot.docs) {
        final docId = doc.id;
        final data = doc.data();
        if (!seenIds.contains(docId) && data != null && mounted) {
          NotificationMessage.show(
            title: "Notification",
            message: data['message'] ?? '',
            backGroundColor: Colors.blue,
            textColor: Colors.white,
          );
          seenIds.add(docId);
          updated = true;
        }
      }
      if (updated) {
        await prefs.setStringList('seenParentNotificationIds', seenIds);
      }
    });
  }

  void _listenToPickupNotifications(String userId) {
    _pickupNotificationSubscription?.cancel();
    _pickupNotificationSubscription = FirebaseFirestore.instance
        .collection('pickupNotifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      parentController.pickupNotificationsList.value =
          snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _pickupNotificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03)
              .copyWith(top: screenHeight * 0.07),
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
                    // IconButton(
                    //   onPressed: () {
                    //     Get.dialog(
                    //       CustomDialogBox(
                    //         buttonName: "Log Out",
                    //         title: "Are you sure you want to logout?",
                    //         onTap: () {
                    //           authController.logout();
                    //         },
                    //       ),
                    //     );
                    //   },
                    //   icon: Icon(
                    //     Icons.logout,
                    //     color: Colors.red,
                    //     size: screenWidth * 0.08,
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                GreenText(
                  text: "Parent Dashboard",
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: screenHeight * 0.02),
                Obx(() {
                  if (userIdController.userId.value.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  bool hasChild = userIdController.childNames.isNotEmpty;

                  return hasChild
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.addChildView);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01,
                          ),
                          margin: EdgeInsets.only(bottom: screenHeight*.01),
                          decoration: BoxDecoration(
                            color: AppColors.yellowColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: GreenText(
                            text: "Add Child",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: [
                          userIdController.childNames.length,
                          userIdController.childIds.length,
                          userIdController.pickup.length,
                          userIdController.buses.length,
                          userIdController.classNos.length,
                        ].reduce((a, b) => a < b ? a : b),
                        itemBuilder: (context, index) {
                          if (index >= userIdController.childNames.length ||
                              index >= userIdController.childIds.length ||
                              index >= userIdController.pickup.length ||
                              index >= userIdController.buses.length ||
                              index >= userIdController.classNos.length) {
                            return SizedBox();
                          }
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: screenHeight * 0.02,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.02,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  screenHeight * 0.02,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      ProfileContainer(),
                                      SizedBox(width: screenWidth * 0.03),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          GreenText(
                                            text: userIdController
                                                .childNames[index],
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          GreenText(
                                            text:
                                            "${userIdController.classNos[index]}",
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Expanded(
                                        child: YellowButton(
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
                                      return Obx(() => parentController.childLoading[userIdController.childIds[index]] == true
                                          ? AppLoader2() // Show loader when loading for this child
                                          : YellowButton(
                                        onTap: () {
                                          String childId = userIdController
                                              .childIds[index];
                                          parentController.notifySchool(childId);
                                        },
                                        text: "I've Arrived - Notify School",
                                        borderRadius: 20,
                                      ));
                                    } else {
                                      return Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          GreenText(
                                            text:
                                            "Driver will pick up : ${userIdController.childNames[index]}",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          const Divider(),
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
                                                    onTap: () {
                                                      Get.toNamed(AppRoutes.trackPickup, arguments: {'childId': userIdController.childIds[index]});
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
                      ),
                      GreenText(
                        onTap: () {
                          Get.toNamed(AppRoutes.viewAllChild);
                        },
                        text: "View All",
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ],
                  )
                      : AddChildCard(
                    onTap: () {
                      Get.toNamed(AppRoutes.addChildView);
                    },
                  );
                }),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    // Expanded(
                    //   child: PickUpTrackCard(
                    //     onTap: () {
                    //       Get.toNamed(AppRoutes.trackPickup);
                    //     },
                    //     image: AppImages.location,
                    //     title: "Track Pickup",
                    //     description: "Add a child to enable tracking",
                    //   ),
                    // ),
                    // SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: PickUpTrackCard(
                        onTap: () {
                          Get.toNamed(AppRoutes.pickUpHistory);
                        },
                        image: AppImages.clock,
                        title: "Pickup History",
                        description: "Add a child to view history",
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.06),
                    Expanded(
                      child: PickUpTrackCard(
                        onTap: () {
                          Get.toNamed(AppRoutes.pickUpNotification);
                        },
                        image: AppImages.bell,
                        title: "Notifications",
                        description: "Add a child to receive alerts",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                YellowButton(
                  onTap: () {
                    Get.toNamed(AppRoutes.helpAndFaq);
                  },
                  text: "Help / FAQ",
                  color: Colors.white,
                  image: AppImages.help,
                  height: screenHeight * 0.05,
                ),
                SizedBox(height: screenHeight * 0.03),
                GreenText(
                  text: "Pro tip: The more Kids, the merrier (but we don't judge!)",
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}