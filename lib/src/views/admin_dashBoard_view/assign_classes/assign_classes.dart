import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/common_widgets/multi_select_widget.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_controller/admin_controller.dart';

class AssignClasses extends StatelessWidget {
  AssignClasses({super.key});

  // Initialize AdminController using GetX dependency injection
  final AdminController adminController = Get.find<AdminController>();

  // Stream to fetch teachers from Firestore where role is 'Teacher'
  Stream<QuerySnapshot> getTeachers() {
    return FirebaseFirestore.instance
        .collection('userData')
        .where('role', isEqualTo: 'Teacher')
        .snapshots();
  }

  // Function to show teacher details in a dialog box
  void showTeacherDetails(BuildContext context, Map<String, dynamic> teacherData, String teacherId) {
    // Extract teacher details from Firestore data
    final teacherName = teacherData['name'] ?? 'Unknown';
    final teacherEmail = teacherData['email'] ?? 'N/A';
    List<String> currentClasses = [];
    final classesData = teacherData['classes'];
    if (classesData is String && classesData.isNotEmpty) {
      currentClasses = [classesData];
    } else if (classesData is Iterable) {
      currentClasses = List<String>.from(classesData);
    }

    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Show dialog with teacher details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        // Dialog title
        title: Text(
          'Teacher Details',
          style: TextStyle(
            fontSize: screenWidth * 0.05, // Responsive font size (5% of screen width)
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
        // Dialog content with teacher details
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GreenText(
                text: 'Name: $teacherName',
                fontSize: screenWidth * 0.04, // Responsive font size
                fontWeight: FontWeight.w400,
                textColor: AppColors.darkBlue,
              ),
              SizedBox(height: screenHeight * 0.015), // Responsive spacing
              GreenText(
                text: 'Email: $teacherEmail',
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
                textColor: AppColors.darkBlue,
              ),
              SizedBox(height: screenHeight * 0.015),
              GreenText(
                text: 'Classes: ${currentClasses.isEmpty ? 'None' : currentClasses.join(', ')}',
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
                textColor: AppColors.darkBlue,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        // Dialog actions
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      // AppBar for the screen
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        title: GreenText(
          text: "Assign Classes",
          fontSize: screenWidth * 0.065, // Responsive font size
          fontWeight: FontWeight.w800,
          textColor: AppColors.darkBlue,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      // Body with StreamBuilder to fetch and display teachers
      body: StreamBuilder<QuerySnapshot>(
        stream: getTeachers(),
        builder: (context, snapshot) {
          // Show loader while data is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Apploader3());
          }
          // Show error if data fetch fails
          if (snapshot.hasError) {
            return Center(child: Text('Error'));
          }
          // Show message if no teachers are found
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No teacher found'));
          }

          // Build a list of teacher cards
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // Responsive padding
              vertical: screenHeight * 0.01,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final teacher = snapshot.data!.docs[index];
              final teacherId = teacher.id;
              final teacherName = teacher['name'] ?? 'Unknown';
              final teacherData = teacher.data() as Map<String, dynamic>;

              // Handle classes data (string or list)
              List<String> currentClasses = [];
              final classesData = teacher['classes'];
              if (classesData is String && classesData.isNotEmpty) {
                currentClasses = [classesData];
              } else if (classesData is Iterable) {
                currentClasses = List<String>.from(classesData);
              }

              // Initialize selected classes for the teacher as RxList
              if (!adminController.selectedClasses.containsKey(teacherId)) {
                adminController.setSelectedClasses(teacherId, currentClasses);
              }

              // Teacher card container
              return Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.05), // Responsive border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teacher name
                    GreenText(
                      text: "Name : $teacherName",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.darkBlue,
                    ),
                    // View Detail button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            GreenText(
                              onTap: () {
                                showTeacherDetails(context, teacherData, teacherId);
                              },
                              text: "View Detail",
                              textColor: Colors.blue,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(width: screenWidth * 0.012),
                            Icon(
                              Icons.info_outline,
                              size: screenWidth * 0.04,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Multi-select grades widget
                    Obx(() => MultiSelectGradeWidget(
                      teacherId: teacherId,
                      grades: adminController.grades,
                      selectedGrades: adminController.selectedClasses[teacherId]!.obs, // Convert to RxList
                    )),
                    SizedBox(height: screenHeight * 0.02),
                    // Assign Classes button
                    Obx(() => YellowButton(
                      text: adminController.getDriverLoadingState(teacherId)
                          ? "Assigning..."
                          : "Assign Classes",
                      onTap: adminController.getDriverLoadingState(teacherId)
                          ? null
                          : () async {
                        if (adminController.getSelectedClasses(teacherId).isNotEmpty) {
                          await adminController.assignClassToTeacher(
                            teacherId,
                            teacherName,
                            adminController.getSelectedClasses(teacherId),
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please select at least one class',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      borderRadius: screenWidth * 0.03,
                      color: AppColors.yellowColor,
                      textColor: AppColors.darkBlue,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w700,
                      borderColor: Colors.transparent,
                      height: screenHeight * 0.06,
                      width: double.infinity,
                    )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}