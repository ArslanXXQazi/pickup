import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_controller/admin_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';

class AllChildDetail extends StatefulWidget {
  const AllChildDetail({super.key});

  @override
  State<AllChildDetail> createState() => _AllChildDetailState();
}

class _AllChildDetailState extends State<AllChildDetail> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSizeLarge = screenWidth * 0.05;
    final fontSizeMedium = screenWidth * 0.04;
    final paddingHorizontal = screenWidth * 0.04;
    final paddingVertical = screenHeight * 0.02;
    final avatarRadius = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: GreenText(
          text: "All Children Details",
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: AppColors.yellowColor,
        elevation: 1,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal,
          vertical: paddingVertical,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('addChild').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoader2();
            }
            if (snapshot.hasError) {
              return Center(
                child: GreenText(
                  text: 'Error: ${snapshot.error}',
                  fontSize: fontSizeMedium,
                  textColor: Colors.red,
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: GreenText(
                  text: 'No children found',
                  fontSize: fontSizeMedium,
                  textColor: Colors.black54,
                ),
              );
            }
            final childrenDocs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: childrenDocs.length,
              itemBuilder: (context, index) {
                var childDoc = childrenDocs[index];
                var childData = childDoc.data() as Map<String, dynamic>;
                var childName = childData['childName'] ?? 'N/A';
                var className = childData['class'] ?? 'N/A';
                var pickup = childData['pickup'] ?? 'N/A';
                var bus = childData['bus'] ?? '';
                var userId = childData['userId'] ?? '';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: EdgeInsets.only(top: screenHeight * .015),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: AssetImage(AppImages.boy),
                      ),
                      title: GreenText(
                        text: childName,
                        fontSize: fontSizeLarge,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.start,
                      ),
                      tilePadding: EdgeInsets.symmetric(
                        horizontal: paddingHorizontal,
                        vertical: paddingVertical * 0.5,
                      ),
                      childrenPadding: EdgeInsets.symmetric(
                        horizontal: paddingHorizontal,
                        vertical: paddingVertical * 0.5,
                      ),
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      iconColor: Colors.black87,
                      collapsedIconColor: Colors.black87,
                      initiallyExpanded: expandedIndex == index,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          expandedIndex = expanded ? index : null;
                        });
                      },
                      children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('userData').doc(userId).get(),
                          builder: (context, parentSnapshot) {
                            if (parentSnapshot.connectionState == ConnectionState.waiting) {
                              return Apploader3();
                            }
                            String fatherName = 'N/A';
                            if (parentSnapshot.hasData && parentSnapshot.data != null && parentSnapshot.data!.exists) {
                              var parentData = parentSnapshot.data!.data() as Map<String, dynamic>;
                              fatherName = parentData['name'] ?? 'N/A';
                            }
                            return Padding(
                              padding:  EdgeInsets.only(bottom: screenHeight*.01),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GreenText(
                                    text: 'Father Name: $fatherName',
                                    fontSize: fontSizeMedium,
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.start,
                                  ),
                                  Divider(color: Colors.blue,),
                                  GreenText(
                                    text: 'Grade: $className',
                                    fontSize: fontSizeMedium,
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.start,
                                  ),
                                  Divider(color: Colors.blue,),
                                  GreenText(
                                    text: pickup == 'Self Pickup'
                                        ? 'Pickup: Self Pickup'
                                        : 'Pickup: Driver Pickup (${bus.isNotEmpty ? bus : 'No bus assigned'})',
                                    fontSize: fontSizeMedium,
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}