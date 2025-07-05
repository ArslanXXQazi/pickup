import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/common_widgets/custom_dialog_box.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/utills/snackbar.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';
import 'package:pick_up_pal/src/views/teacher_dashbord_view/teacher_controller/teacher_controller.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherDashbordView extends StatefulWidget {
  TeacherDashbordView({super.key});

  @override
  State<TeacherDashbordView> createState() => _TeacherDashbordViewState();
}

class _TeacherDashbordViewState extends State<TeacherDashbordView> {
  final AuthController authController = Get.put(AuthController());
  final TeacherController teacherController = Get.put(TeacherController());
  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  String? _lastNotificationId;

  @override
  void initState() {
    super.initState();
    _loadLastNotificationId();
    teacherController.userIdController.getUserIdAndRole().then((_) {
      final teacherId = teacherController.userIdController.userId.value;
      print('TeacherId for stream: ' + teacherId);
      if (teacherId.isNotEmpty) {
        _listenToTeacherNotifications(teacherId);
      }
    });
  }

  Future<void> _loadLastNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
  }

  void _listenToTeacherNotifications(String teacherId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = FirebaseFirestore.instance
        .collection('teacherNotifications')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) async {
      final prefs = await SharedPreferences.getInstance();
      List<String> seenIds = prefs.getStringList('seenTeacherNotificationIds') ?? [];
      bool updated = false;
      final oneMinuteAgo = DateTime.now().subtract(Duration(minutes: 1));
      for (var doc in snapshot.docs) {
        final docId = doc.id;
        final data = doc.data();
        if (data == null) continue;
        final notifTime = DateTime.tryParse(data['timestamp'] ?? '');
        if (notifTime == null || notifTime.isBefore(oneMinuteAgo)) continue;
        print('New teacher notification: ' + data.toString());
        if (!seenIds.contains(docId) && mounted) {
          String message = data['message'] ?? '';
          NotificationMessage.show(
            title: "Notification",
            message: message,
            backGroundColor: Colors.blue,
            textColor: Colors.white,
          );
          seenIds.add(docId);
          updated = true;
        }
      }
      if (updated) {
        await prefs.setStringList('seenTeacherNotificationIds', seenIds);
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

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03)
              .copyWith(top: screenHeight * 0.07),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppLogo(
                    height: screenHeight * 0.08,
                    width: screenHeight * 0.08,
                    iconSize: screenHeight * 0.06,
                    borderRadius: screenHeight * 0.017,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  GreenText(
                    text: "Teacher\nDashBord",
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.left,
                  ),
                  const Spacer(),
                  ProfileContainer(
                    ontap: (){
                      Get.toNamed(AppRoutes.driverProfileView);
                    },
                      color: Colors.blue),

                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Obx(
                    () => YellowButton(
                  onTap: () {},
                  text: "Welcome, ${teacherController.teacherName.value}",
                  color: Colors.white,
                  borderRadius: screenHeight * 0.025,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Obx(
                    () => YellowButton(
                  onTap: () {},
                  text: "Currently managing: ${teacherController.assignedClasses.isNotEmpty ? teacherController.assignedClasses.join(', ') : 'No grades assigned'}",
                  color: Colors.white,
                  borderRadius: screenHeight * 0.025,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                height: screenHeight * 0.30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenHeight * 0.025),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 20,
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.012),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.yellowColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(screenHeight * 0.025),
                            topLeft: Radius.circular(screenHeight * 0.025),
                          ),
                        ),
                        child: Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
                          child: GreenText(
                            text: "Pickup Queue",
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            textColor: Colors.black,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 80,
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
                        child: SingleChildScrollView(
                          child: Obx(
                                () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.012),
                                if (teacherController.pickupQueueStudents.isEmpty)
                                  GreenText(
                                    text: "No students in pickup queue",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black54,
                                    textAlign: TextAlign.left,
                                  ),
                                ...teacherController.pickupQueueStudents.map((student) {
                                  return PickupQueueWidget(
                                    title: student['childName']!,
                                    description: student['description']!,
                                    parentNotified: student['parentNotified'],
                                    pickedUp: student['pickedUp'],
                                    childId: student['childId'],
                                    onPickup: () => teacherController.markPickup(student['childId']),
                                    teacherController: teacherController,
                                  );
                                }).toList(),
                                SizedBox(height: screenHeight * 0.018),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.018),
              Obx(
                    () => HistoryNotificationWidget(
                  title: "Notification",
                  description: teacherController.arrivedParentsCount.value == 0
                      ? "No parent has arrived"
                      : teacherController.arrivedParentsCount.value == 1
                          ? "1 parent has arrived"
                          : "${teacherController.arrivedParentsCount.value} parents have arrived",
                  backColor: AppColors.lightBlue.withOpacity(.3),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Obx(
                () => HistoryNotificationWidget(
                  title: "History",
                  description: teacherController.completedPickupsCount.value == 0
                      ? "No pickups completed"
                      : teacherController.completedPickupsCount.value == 1
                          ? "1 pickup completed"
                          : "${teacherController.completedPickupsCount.value} pickups completed",
                  icon: Icons.access_time_filled_outlined,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              GreenText(
                text: "PickUpPal",
                fontSize: 30,
                fontWeight: FontWeight.w900,
                textColor: Colors.blue.shade900,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PickupQueueWidget extends StatelessWidget {
  final String title;
  final String description;
  final bool parentNotified;
  final bool pickedUp;
  final String childId;
  final VoidCallback onPickup;
  final TeacherController teacherController;

  PickupQueueWidget({
    super.key,
    required this.title,
    required this.description,
    required this.parentNotified,
    required this.pickedUp,
    required this.childId,
    required this.onPickup,
    required this.teacherController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreenText(
                    text: title,
                    fontWeight: FontWeight.bold,
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    children: [
                      GreenText(
                        text: description,
                        textColor: description == 'Parent Arrived' ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        textAlign: TextAlign.left,
                      ),
                      if (parentNotified && !pickedUp) SizedBox(width: 5),
                      if (parentNotified && !pickedUp)
                        Icon(Icons.check, color: Colors.green, size: 18),
                    ],
                  ),
                ],
              ),
            ),
            if (parentNotified)
              Expanded(
                flex: 30,
                child: Obx(() {
                  if (teacherController.loadingPickupChildId.value == childId) {
                    return AppLoader2();
                  }
                  String btnText = "Pickup";
                  Color btnColor = AppColors.yellowColor;
                  bool btnEnabled = !pickedUp;
                  if (pickedUp) {
                    btnText = "Picked Up";
                    btnColor = Colors.green;
                    btnEnabled = false;
                  } else if (parentNotified && !pickedUp) {
                    btnText = "Pickup";
                    btnColor = AppColors.yellowColor;
                    btnEnabled = true;
                  }
                  return YellowButton(
                    onTap: btnEnabled ? () {
                      onPickup();
                      NotificationMessage.show(
                        title: "Success",
                        message: "You have picked up the child.",
                        backGroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    } : null,
                    text: btnText,
                    height: 40,
                    fontSize: 14,
                    borderRadius: 10,
                    color: btnColor,
                    textColor: btnEnabled ? AppColors.darkBlue : Colors.white,
                  );
                }),
              ),
          ],
        ),
        Divider(),
      ],
    );
  }
}