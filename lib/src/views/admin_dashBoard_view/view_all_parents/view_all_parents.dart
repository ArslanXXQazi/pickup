import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/utills/app_loader.dart';

class ViewAllParents extends StatelessWidget {
  const ViewAllParents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSizeLarge = screenWidth * 0.05; // Responsive font size for titles
    final fontSizeMedium = screenWidth * 0.04; // Responsive font size for child details
    final paddingHorizontal = screenWidth * 0.04; // Responsive horizontal padding
    final paddingVertical = screenHeight * 0.02; // Responsive vertical padding
    final avatarRadius = screenWidth * 0.06; // Responsive avatar size

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: GreenText(
          text: "Parent Details",
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
          stream: FirebaseFirestore.instance
              .collection('userData')
              .where('role', isEqualTo: 'Parent')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
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
                  text: 'No parents found',
                  fontSize: fontSizeMedium,
                  textColor: Colors.black54,
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var parentDoc = snapshot.data!.docs[index];
                var parentId = parentDoc['userId'];
                var parentName = parentDoc['name'] ?? 'Unknown Parent';

                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding:  EdgeInsets.only(top: screenHeight*.015),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: AssetImage(AppImages.boy),
                      ),
                      title: GreenText(
                        text: parentName,
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
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('addChild')
                              .where('userId', isEqualTo: parentId)
                              .snapshots(),
                          builder: (context, childSnapshot) {
                            if (childSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: Apploader3());
                            }
                            if (childSnapshot.hasError) {
                              return GreenText(
                                text: 'Error: ${childSnapshot.error}',
                                fontSize: fontSizeMedium,
                                textColor: Colors.red,
                              );
                            }
                            if (!childSnapshot.hasData || childSnapshot.data!.docs.isEmpty) {
                              return GreenText(
                                text: 'No children found',
                                fontSize: fontSizeMedium,
                                textColor: Colors.black54,
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: childSnapshot.data!.docs.asMap().entries.map((entry) {
                                var idx = entry.key + 1; // Start numbering from 1
                                var childDoc = entry.value;
                                var childData = childDoc.data() as Map<String, dynamic>;
                                var childName = childData['childName'] ?? 'N/A';
                                var childClass = childData['class'] ?? 'N/A';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(),
                                    GreenText(
                                      text: '$idx. Child Name: $childName',
                                      fontSize: fontSizeMedium,
                                      fontWeight: FontWeight.w600,
                                      textAlign: TextAlign.start,
                                    ),
                                    GreenText(
                                      text: '    Grade: $childClass',
                                      fontSize: fontSizeMedium,
                                      fontWeight: FontWeight.w600,
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                );
                              }).toList(),
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