import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_controller/admin_controller.dart';

class AssignBusView extends StatelessWidget {
  AssignBusView({super.key});

  final AdminController adminController = Get.find<AdminController>();

  Stream<QuerySnapshot> getDrivers() {
    return FirebaseFirestore.instance
        .collection('userData')
        .where('role', isEqualTo: 'Driver')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Ensure assigned buses are fetched when view is initialized
    adminController.fetchAssignedBuses();

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        title: GreenText(
          text: "Assign Buses",
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getDrivers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Apploader3());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No drivers found'));
          }

          final drivers = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.025,
              vertical: screenHeight * 0.03,
            ),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              final driverId = driver.id;
              final driverName = driver['name'] ?? 'Unknown';
              final assignedBus = driver['busses'] ?? ''; // Fetch assigned bus from Firestore

              // Initialize selected bus if not already set
              if (assignedBus.isNotEmpty && adminController.getSelectedBus(driverId).isEmpty) {
                adminController.setSelectedBus(driverId, assignedBus);
              }

              return DriverBusCard(
                driverId: driverId,
                driverName: driverName,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                adminController: adminController,
              );
            },
          );
        },
      ),
    );
  }
}

class DriverBusCard extends StatelessWidget {
  final String driverId;
  final String driverName;
  final double screenHeight;
  final double screenWidth;
  final AdminController adminController;

  DriverBusCard({
    required this.driverId,
    required this.driverName,
    required this.screenHeight,
    required this.screenWidth,
    required this.adminController,
  });

  // Inline Bus Selection Widget
  Widget _buildBusSelector(BuildContext context) {
    // Get available buses (excluding those assigned to other drivers)
    List<String> getAvailableBuses() {
      final assignedBuses = adminController.selectedBuses.entries
          .where((entry) => entry.key != driverId)
          .map((entry) => entry.value)
          .toList();
      // Include current driver's bus (if any) to avoid selection issues
      final availableBuses = adminController.busses
          .where((bus) => !assignedBuses.contains(bus) || bus == adminController.getSelectedBus(driverId))
          .toList();
      // Add "None" option to allow unassigning
      return ['None', ...availableBuses];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GreenText(
          text: "Select Bus",
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          height: screenHeight * 0.06,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.darkBlue, width: 2.5),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            color: Colors.white,
          ),
          child: GestureDetector(
            onTap: () {
              // Initialize temporary selected bus
              RxString tempSelectedBus = RxString(adminController.getSelectedBus(driverId));
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: GreenText(
                      text: "Select Bus",
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: getAvailableBuses().map((bus) {
                          return Obx(() {
                            final isSelected = tempSelectedBus.value == bus;
                            return RadioListTile<String>(
                              activeColor: AppColors.yellowColor,
                              title: GreenText(
                                text: bus,
                                fontWeight: FontWeight.w700,
                              ),
                              value: bus,
                              groupValue: tempSelectedBus.value,
                              onChanged: (value) {
                                if (value != null) {
                                  tempSelectedBus.value = value;
                                }
                              },
                            );
                          });
                        }).toList(),
                      ),
                    ),
                    actions: [
                      GreenText(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        text: "Cancel",
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      GreenText(
                        onTap: () {
                          adminController.setSelectedBus(driverId, tempSelectedBus.value == 'None' ? '' : tempSelectedBus.value);
                          Navigator.pop(context);
                        },
                        text: "Done",
                        fontWeight: FontWeight.w700,
                        textColor: Colors.green,
                      ),
                    ],
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(() {
                    final displayBus = adminController.getSelectedBus(driverId).isEmpty
                        ? "Select Bus"
                        : adminController.getSelectedBus(driverId);
                    return Text(
                      displayBus,
                      style: TextStyle(
                        color: displayBus == "Select Bus" ? Colors.grey : Colors.black,
                        fontSize: screenWidth * 0.04,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.darkBlue,
                  size: screenWidth * 0.06,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.01,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreenText(
            text: "Driver: $driverName",
            fontSize: 18,
            fontWeight: FontWeight.w700,
            textColor: AppColors.darkBlue,
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildBusSelector(context), // Use inline bus selector widget
          SizedBox(height: screenHeight * 0.03),
          Obx(() => adminController.getDriverLoadingState(driverId)
              ? AppLoader2()
              : YellowButton(
            text: "Assign Now",
            onTap: () {
              if (adminController.getSelectedBus(driverId).isNotEmpty) {
                adminController.assignBus(
                    driverId, driverName, adminController.getSelectedBus(driverId));
              } else {
                Get.snackbar(
                  'Error',
                  'Please select a bus',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            height: 50,
            width: double.infinity,
            borderRadius: 10,
            color: AppColors.yellowColor,
            textColor: AppColors.darkBlue,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            borderColor: AppColors.darkBlue,
          )),
        ],
      ),
    );
  }
}