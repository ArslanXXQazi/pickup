import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pick_up_pal/src/controller/common_widgets/custom_dialog_box.dart';
import 'package:pick_up_pal/src/controller/common_widgets/student_row.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';
import '../../controller/constant/linkers/linkers.dart';
import '../track_pickup/google_map_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pick_up_pal/src/utills/snackbar.dart';

class DriverDashBordView extends StatefulWidget {
  const DriverDashBordView({super.key});

  @override
  State<DriverDashBordView> createState() => _DriverDashBordViewState();
}

class _DriverDashBordViewState extends State<DriverDashBordView> {
  final GoogleMapControllerX mapController = Get.put(GoogleMapControllerX());
  final DriverController controller = Get.put(DriverController());
  final AuthController authController = Get.put(AuthController());
  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  String? _lastNotificationId;

  @override
  void initState() {
    super.initState();
    _loadLastNotificationId();
    controller.userIdController.getUserIdAndRole().then((_) {
      final driverId = controller.userIdController.userId.value;
      if (driverId.isNotEmpty) {
        _listenToDriverNotifications(driverId);
      }
    });
    mapController.startLocationUpdates();
    ever(controller.driverName, (_) {
      mapController.setDriverInfo(
        name: controller.driverName.value,
        busName: controller.userIdController.buses.isNotEmpty ? controller.userIdController.buses.first : '',
      );
    });
    ever(controller.userIdController.buses, (_) {
      mapController.setDriverInfo(
        name: controller.driverName.value,
        busName: controller.userIdController.buses.isNotEmpty ? controller.userIdController.buses.first : '',
      );
    });
  }

  Future<void> _loadLastNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
  }

  void _listenToDriverNotifications(String driverId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = FirebaseFirestore.instance
        .collection('driverNotifications')
        .where('driverId', isEqualTo: driverId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        final docId = doc.id;
        final prefs = await SharedPreferences.getInstance();
        final lastSeenId = prefs.getString('lastDriverNotificationId');
        if (data != null && mounted && docId != lastSeenId) {
          await prefs.setString('lastDriverNotificationId', docId);
          controller.lastNotificationId.value = docId;
          NotificationMessage.show(
            title: "Notification",
            message: data['message'] ?? '',
            backGroundColor: Colors.orange,
            textColor: Colors.white,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth * 0.03;
    final RxBool isLocationShared = true.obs; // Local observable for switch

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.14,
            color: AppColors.yellowColor,
            padding: EdgeInsets.only(bottom: basePadding * 0.5),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: basePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppLogo(
                        height: screenWidth * 0.15,
                        width: screenWidth * 0.15,
                        iconSize: screenWidth * 0.12,
                        borderRadius: screenWidth * 0.04,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      GreenText(
                        text: "PickupPal",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      const Spacer(),
                      ProfileContainer(
                        ontap: () {
                          Get.toNamed(AppRoutes.driverProfileView);
                        },
                      ),
                      SizedBox(width: basePadding * 0.4),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth*.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  GreenText(
                    text: "Driver Dashboard",
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: screenHeight * 0.35,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: basePadding * 0.9,
                      vertical: basePadding * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: screenWidth * 0.015,
                          offset: Offset(0, screenWidth * 0.005),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GreenText(
                            text: "Assigned Students",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Obx(() {
                            if (controller.isLoading.value) {
                              return Center(
                                child: AppLoader2(),
                              );
                            }
                            if (controller.assignedChildren.isEmpty) {
                              return Text(
                                "No students assigned",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: controller.assignedChildren.length,
                              itemBuilder: (context, index) {
                                var child = controller.assignedChildren[index];
                                return StudentRow(
                                  ontap: () {
                                    showStatusDialog(
                                      context,
                                      controller,
                                      child['docId']!,
                                      child['childName']!,
                                    );
                                  },
                                  studentName: child['childName']!,
                                  buttonText: child['status'],
                                  buttonColor: child['status'] == 'Onboard'
                                      ? Colors.blue
                                      : child['status'] == 'Dropped Off'
                                      ? AppColors.yellowColor
                                      : Colors.blue.shade100,
                                  textColor: child['status'] == 'Onboard'
                                      ? Colors.white
                                      : AppColors.darkBlue,
                                  isLoading: controller.childStatusLoading[child['docId']] == true,
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  GreenText(
                    text: "Live Location",
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    height: screenHeight * 0.25,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: screenWidth * 0.015,
                          offset: Offset(0, screenWidth * 0.005),
                        ),
                      ],
                    ),
                    child: Obx(() {
                      if (mapController.isLoading.value) {
                        return Center(child: AppLoader2());
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(mapController.latitude.value, mapController.longitude.value),
                            zoom: 16,
                          ),
                          myLocationEnabled: false,
                          myLocationButtonEnabled: true,
                          trafficEnabled: true,
                          markers: mapController.allMarkers,
                          polylines: mapController.polylines.value,
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GreenText(
                        text: "Share Location",
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: controller.isLocationShared.value,
                          onChanged: (value) {
                            controller.toggleLocationSharing(value);
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Colors.blue,
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showStatusDialog(BuildContext context, DriverController controller, String docId, String childName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: GreenText(
            text: "Update Status for $childName",
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              controller.loadingStatusButton.value == docId + "Not Picked Up"
                  ? const AppLoader2()
                  : YellowButton(
                onTap: () async {
                  await controller.updateChildStatus(docId, "Not Picked Up", onComplete: () {
                    Navigator.pop(context);
                  });
                },
                text: "Not Picked Up",
                color: Colors.blue.shade100,
                textColor: AppColors.darkBlue,
                fontSize: 14,
                height: 40,
                borderRadius: 8,
                borderColor: Colors.transparent,
              ),
              SizedBox(height: 10),
              controller.loadingStatusButton.value == docId + "Onboard"
                  ? const AppLoader2()
                  : YellowButton(
                onTap: () async {
                  await controller.updateChildStatus(docId, "Onboard", onComplete: () {
                    Navigator.pop(context);
                  });
                },
                text: "Onboard",
                color: Colors.blue,
                textColor: Colors.white,
                fontSize: 14,
                height: 40,
                borderRadius: 8,
                borderColor: Colors.transparent,
              ),
              SizedBox(height: 10),
              controller.loadingStatusButton.value == docId + "Dropped Off"
                  ? const AppLoader2()
                  : YellowButton(
                onTap: () async {
                  await controller.updateChildStatus(docId, "Dropped Off", onComplete: () {
                    Navigator.pop(context);
                  });
                },
                text: "Dropped Off",
                color: AppColors.yellowColor,
                textColor: AppColors.darkBlue,
                fontSize: 14,
                height: 40,
                borderRadius: 8,
                borderColor: Colors.transparent,
              ),
            ],
          )),
        );
      },
    );
  }
}