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

class _ParentDashbordState extends State<ParentDashbord> with WidgetsBindingObserver {
  final UserId userIdController = Get.find<UserId>();
  final AuthController authController = Get.put(AuthController());
  final ParentController parentController = Get.find<ParentController>();

  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  StreamSubscription<QuerySnapshot>? _pickupNotificationSubscription;
  String? _lastNotificationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastNotificationId();
    userIdController.getUserIdAndRole().then((_) {
      if (userIdController.userId.value.isNotEmpty) {
        userIdController.getChildData();
        userIdController.getChildStatusStream();
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
      final threeMinutesAgo = DateTime.now().subtract(Duration(minutes: 3));
      for (var doc in snapshot.docs) {
        final docId = doc.id;
        final data = doc.data();
        if (data == null) continue;
        DateTime? notifTime;
        var ts = data['timestamp'];
        if (ts is Timestamp) {
          notifTime = ts.toDate();
        } else if (ts is String) {
          notifTime = DateTime.tryParse(ts);
        }
        if (notifTime == null || notifTime.isBefore(threeMinutesAgo)) continue;
        if (!seenIds.contains(docId) && mounted) {
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
        .snapshots()
        .listen((snapshot) async {
      final prefs = await SharedPreferences.getInstance();
      List<String> seenIds = prefs.getStringList('seenParentNotificationIds') ?? [];
      bool updated = false;
      final threeMinutesAgo2 = DateTime.now().subtract(Duration(minutes: 3));
      print('Snapshot docs (parent stream): ' + snapshot.docs.map((doc) => doc.data().toString()).join('\n'));
      // Only show notifications from the last 3 minutes (teacher + driver)
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        if (data == null || data['timestamp'] == null) return false;
        DateTime? notifTime;
        var ts = data['timestamp'];
        if (ts is Timestamp) {
          notifTime = ts.toDate();
        } else if (ts is String) {
          notifTime = DateTime.tryParse(ts);
        }
        if (notifTime == null) return false;
        return notifTime.isAfter(threeMinutesAgo2);
      }).toList();
      print('Filtered notifications (parent stream): ' + filteredDocs.map((doc) => doc.data().toString()).join('\n'));
      for (var doc in filteredDocs) {
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
      parentController.pickupNotificationsList.value =
          filteredDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      print('pickupNotificationsList (parent stream): ' + parentController.pickupNotificationsList.toString());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription?.cancel();
    _pickupNotificationSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      userIdController.getChildData();
      userIdController.getChildStatusStream();
    }
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
                  print('ParentDashbord: childNames = \\${userIdController.childNames}');
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
                        itemCount: min(3, [
                          userIdController.childNames.length,
                          userIdController.childIds.length,
                          userIdController.pickup.length,
                          userIdController.childBuses.length,
                          userIdController.classNos.length,
                        ].reduce((a, b) => a < b ? a : b)),
                        itemBuilder: (context, index) {
                          String childId = userIdController.childIds[index];
                          parentController.checkAndResetStatus(childId);
                          print('ParentDashbord: itemCount = \\${[
                            userIdController.childNames.length,
                            userIdController.childIds.length,
                            userIdController.pickup.length,
                            userIdController.childBuses.length,
                            userIdController.classNos.length,
                          ].reduce((a, b) => a < b ? a : b)}, childNames = \\${userIdController.childNames}, childIds = \\${userIdController.childIds}, pickup = \\${userIdController.pickup}, childBuses = \\${userIdController.childBuses}, classNos = \\${userIdController.classNos}');
                          if (index >= userIdController.childNames.length ||
                              index >= userIdController.childIds.length ||
                              index >= userIdController.pickup.length ||
                              index >= userIdController.childBuses.length ||
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
                                      print('childId: $childId, parentNotified: $parentNotified, pickedUp: $pickedUp, parentConfirmedPickup: $parentConfirmedPickup');
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