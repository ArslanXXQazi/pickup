import 'package:flutter/material.dart';
import 'package:pick_up_pal/src/controller/common_widgets/custom_dialog_box.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_controller/admin_controller.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';

class ManageUserView extends StatelessWidget {
  const ManageUserView({super.key});

  @override
  Widget build(BuildContext context) {
    final UserId userIdController = Get.find<UserId>();
    final AdminController adminController = Get.find<AdminController>();

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    TextEditingController nameController = TextEditingController();
    TextEditingController roleController = TextEditingController();

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
          padding: EdgeInsets.only(
            left: screenWidth * .025,
            right: screenWidth * .025,
            top: screenHeight * .06,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    ProfileContainer(),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                GreenText(
                  text: "Manage User",
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: screenHeight * 0.01),
                YellowButton(
                  text: "Add User",
                  onTap: () {
                    Get.toNamed(AppRoutes.addUsersView);
                  },
                  width: screenWidth * 0.35,
                  height: screenHeight * 0.05,
                  borderRadius: 15,
                  borderColor: Colors.transparent,
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  height: screenHeight * 0.55,
                  width: screenWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * .03,
                    vertical: screenHeight * .02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GreenText(
                            text: "Manage User",
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          SizedBox(height: screenHeight * .005),
                          Divider(color: Colors.blue),
                          SizedBox(height: screenHeight * .005),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GreenText(
                                text: "Name",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              GreenText(
                                text: "Role",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              GreenText(
                                text: "View",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                textColor: Colors.blue,
                              ),
                              GreenText(
                                text: "Block/Unblock",
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                textColor: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight*.02),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection("userData").snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: Apploader3());
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(child: Text("No users found"));
                            }
                            var userDocs = snapshot.data!.docs;
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: userDocs.length,
                              itemBuilder: (context, index) {
                                var userData = userDocs[index].data() as Map<String, dynamic>;
                                String userId = userData['userId'] ?? "";
                                String name = userData['name'] ?? "Unknown";
                                String role = userData['role'] ?? "N/A";
                                String email = userData['email'] ?? "N/A"; // Fetch email
                                bool isBlocked = userData['isBlocked'] ?? false;

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 73,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 40,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    GreenText(
                                                      text: name,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: screenWidth * .03),
                                              Expanded(
                                                flex: 30,
                                                child: GreenText(
                                                  text: role,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              SizedBox(width: screenWidth * .03),
                                              Expanded(
                                                flex: 30,
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Get.dialog(
                                                          AlertDialog(
                                                            backgroundColor: Colors.white,
                                                            title: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                GreenText(
                                                                  text: "User Details",
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                                SizedBox(height: screenHeight * .015),
                                                                GreenText(
                                                                  text: "Name: $name",
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                                SizedBox(height: screenHeight * .01),
                                                                GreenText(
                                                                  text: "Role: $role",
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                                SizedBox(height: screenHeight * .01),
                                                                GreenText(
                                                                  text: "Email: $email", // Show email
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                                SizedBox(height: screenHeight * .015),
                                                                YellowButton(
                                                                  onTap: () {
                                                                    Get.back();
                                                                  },
                                                                  text: "Go Back",
                                                                  height: screenHeight * 0.05,
                                                                  borderRadius: 10,
                                                                  borderColor: Colors.transparent,
                                                                  color: Colors.blue,
                                                                  textColor: Colors.white,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Icon(Icons.remove_red_eye, color: Colors.blue, size: screenHeight * 0.03),
                                                    ),
                                                    SizedBox(width: screenWidth * .01),
                                                    InkWell(
                                                      onTap: () {
                                                        Get.dialog(
                                                          CustomDialogBox(
                                                            title: "Are you sure you want to Delete?",
                                                            buttonName: "Delete",
                                                            onTap: () {
                                                              adminController.deleteUser(userId);
                                                              Get.back();
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: screenHeight * 0.03,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * .12),
                                        Expanded(
                                          flex: 27,
                                          child: YellowButton(
                                            onTap: () {
                                              Get.dialog(
                                                CustomDialogBox(
                                                  title: isBlocked
                                                      ? "Are you sure you want to Unblock?"
                                                      : "Are you sure you want to Block?",
                                                  buttonName: isBlocked ? "Unblock" : "Block",
                                                  onTap: () {
                                                    adminController.toggleBlockUser(userId, isBlocked);
                                                    Get.back();
                                                  },
                                                ),
                                              );
                                            },
                                            height: screenHeight * 0.045,
                                            text: isBlocked ? "Unblock" : "Block",
                                            borderColor: Colors.transparent,
                                            textColor: Colors.white,
                                            color: isBlocked ? Colors.yellow : Colors.red,
                                            borderRadius: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Divider(color: Colors.blue),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}