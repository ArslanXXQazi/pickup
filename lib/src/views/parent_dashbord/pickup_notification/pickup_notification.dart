import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/constant/linkers/linkers.dart';
import '../parent_controller.dart';
import 'package:intl/intl.dart';

class PickupNotification extends StatefulWidget {
  PickupNotification({super.key});

  @override
  State<PickupNotification> createState() => _PickupNotificationState();
}

class _PickupNotificationState extends State<PickupNotification> {
  final ParentController parentController = Get.find<ParentController>();

  @override
  void initState() {
    super.initState();
    parentController.fetchPickupNotifications();
  }

  String formatNotificationTime(String isoTime) {
    final date = DateTime.parse(isoTime).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final aDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(aDate).inDays;
    final timeStr = DateFormat('h:mm a').format(date);
    if (diff == 0) {
      return 'Today $timeStr';
    } else if (diff == 1) {
      return 'Yesterday $timeStr';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Get screen dimensions for responsive design (only for padding and sizes, not font)
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blue.shade200,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: GreenText(
          text: "PickUp Notifications",
          fontWeight: FontWeight.w700,
          fontSize: 22, // Fixed font size for title
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.02,
          right: screenWidth * 0.02,
          top: screenHeight * 0.05,
        ),
        child: Obx(() {
          final notifications = parentController.pickupNotificationsList;
          if (notifications.isEmpty) {
            return Center(
              child: GreenText(
                text: 'No notifications found',
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.025,
                          vertical: screenHeight * 0.02,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GreenText(
                              text: notification["message"] ?? '',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              textAlign: TextAlign.start,
                            ),
                            GreenText(
                              text: formatNotificationTime(notification["timestamp"] ?? ''),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}