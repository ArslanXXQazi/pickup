import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/constant/linkers/linkers.dart';
import '../parent_controller.dart';
import 'package:intl/intl.dart';
import '../../../utills/app_loader.dart';


class PickupHistory extends StatefulWidget {
  PickupHistory({super.key});

  @override
  State<PickupHistory> createState() => _PickupHistoryState();
}

class _PickupHistoryState extends State<PickupHistory> {
  final ParentController parentController = Get.find<ParentController>();

  @override
  void initState() {
    super.initState();
    parentController.fetchPickupHistory(); // Fetch history on screen load
  }

  /// Format time as Today, Yesterday, or date
  String formatPickupTime(String isoTime) {
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
          text: "PickUp History",
          fontWeight: FontWeight.w700,
          fontSize: 22, // Fixed font size for time
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: screenWidth * 0.02,
          right: screenWidth * 0.02,
          top: screenHeight * 0.05,
        ),
        child: Obx(() {
          if (parentController.isHistoryLoading.value) {
            return const Apploader3();
          }
          final history = parentController.pickupHistoryList;
          final droppedOffHistory = history.where((entry) => entry['status'] == 'Dropped Off').toList();
          if (droppedOffHistory.isEmpty) {
            return Center(
              child: GreenText(
                text: 'No pickup history found',
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: droppedOffHistory.length,
                  itemBuilder: (context, index) {
                    final entry = droppedOffHistory[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenHeight * 0.02,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15), // Fixed border radius
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: screenHeight * 0.06,
                              width: screenHeight * 0.06,
                              child: ImageIcon(
                                AssetImage(AppImages.clock),
                                color: AppColors.yellowColor,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GreenText(
                                  text: formatPickupTime(entry['pickupTime'] ?? ''),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18, // Fixed font size for time
                                ),
                                GreenText(
                                  text: entry['childName'] ?? '',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16, // Fixed font size for name
                                ),
                              ],
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