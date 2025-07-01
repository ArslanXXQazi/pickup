import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_controller/admin_controller.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/parent_controller.dart';

class MultiSelectGradeWidget extends StatelessWidget {
  final String? teacherId; // Optional for Admin mode
  final List<String> grades;
  final List<String> selectedGrades; // Reverted to List<String> for compatibility
  final String? Function(String?)? validator;
  final bool isSingleSelection; // Control selection mode

  const MultiSelectGradeWidget({
    Key? key,
    this.teacherId,
    required this.grades,
    required this.selectedGrades,
    this.validator,
    this.isSingleSelection = false, // Default to multiple selection (Admin mode)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final AdminController? adminController = isSingleSelection ? null : Get.find<AdminController>();
    final ParentController? parentController = isSingleSelection ? Get.find<ParentController>() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GreenText(
          text: isSingleSelection ? "Select Grade (Max 1)" : "Select Classes (Max 2)",
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
              // Initialize temporary selected grades as RxList
              RxList<String> tempSelectedGrades = RxList<String>(List.from(selectedGrades));
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: GreenText(
                      text: isSingleSelection ? "Select Grade" : "Select Classes (Max 2)",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: grades.map((grade) {
                          return Obx(() {
                            final isSelected = tempSelectedGrades.contains(grade);
                            final maxLimit = isSingleSelection ? 1 : 2;
                            final canSelect = tempSelectedGrades.length < maxLimit || isSelected;

                            return CheckboxListTile(
                              activeColor: AppColors.yellowColor,
                              tileColor: Colors.transparent,
                              title: Text(
                                grade,
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                              value: isSelected,
                              onChanged: canSelect
                                  ? (bool? value) {
                                if (isSingleSelection && value == true) {
                                  tempSelectedGrades.clear(); // Clear for single selection
                                  tempSelectedGrades.add(grade);
                                } else if (!isSingleSelection && value == true && tempSelectedGrades.length < 2) {
                                  tempSelectedGrades.add(grade);
                                } else if (value == false) {
                                  tempSelectedGrades.remove(grade);
                                }
                              }
                                  : null,
                            );
                          });
                        }).toList(),
                      ),
                    ),
                    actions: [
                      GreenText(
                        onTap: () {
                          if (!isSingleSelection && teacherId != null) {
                            adminController!.cancelDialogSelections(teacherId!);
                          }
                          Navigator.pop(context);
                        },
                        text: "Cancel",
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      GreenText(
                        onTap: () {
                          if (isSingleSelection) {
                            parentController!.selectedGrade.assignAll(tempSelectedGrades);
                          } else if (teacherId != null) {
                            adminController!.setSelectedClasses(teacherId!, tempSelectedGrades.toList());
                          }
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
                    // Use adminController or parentController based on mode
                    final displayGrades = isSingleSelection
                        ? parentController!.selectedGrade
                        : teacherId != null
                        ? adminController!.getSelectedClasses(teacherId!)
                        : selectedGrades;
                    return Text(
                      displayGrades.isEmpty
                          ? (isSingleSelection ? "Select Grade" : "Select Classes")
                          : displayGrades.join(", "),
                      style: TextStyle(
                        color: displayGrades.isEmpty ? Colors.grey : Colors.black,
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
}










// import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
// import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_controller/admin_controller.dart';
//
// class MultiSelectGradeWidget extends StatelessWidget {
//   final String teacherId;
//   final List<String> grades;
//   final List<String> selectedGrades;
//
//   const MultiSelectGradeWidget({
//     Key? key,
//     required this.teacherId,
//     required this.grades,
//     required this.selectedGrades,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions for responsive design
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     // Get AdminController instance
//     final AdminController adminController = Get.find<AdminController>();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label for class selection
//         GreenText(
//           text:  "Select Classes (Max 2)",
//           fontWeight: FontWeight.w700,
//           fontSize: 14,
//         ),
//         SizedBox(height: screenHeight * 0.01),
//         // Dropdown container for selecting classes
//         Container(
//           height: screenHeight * 0.06,
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 0),
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.darkBlue.withOpacity(0.5)),
//             borderRadius: BorderRadius.circular(screenWidth * 0.02),
//             color: Colors.white,
//           ),
//           child: GestureDetector(
//             // Open dialog for class selection
//             onTap: () {
//               adminController.setTempSelectedClasses(teacherId, List.from(selectedGrades));
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     backgroundColor: Colors.white,
//                     // Dialog title
//                     title: GreenText(
//                       text:  "Select Classes (Max 2)",
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     // Dialog content with class checkboxes
//                     content: SingleChildScrollView(
//                       child: Obx(() => Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: adminController.getAvailableGrades(teacherId).map((grade) {
//                           final isSelected = adminController.getTempSelectedClasses(teacherId).contains(grade);
//                           final canSelect = adminController.getTempSelectedClasses(teacherId).length < 2 || isSelected;
//
//                           return CheckboxListTile(
//                             activeColor: AppColors.yellowColor,
//                             tileColor: Colors.transparent,
//                             title: Text(
//                               grade,
//                               style: TextStyle(fontSize: screenWidth * 0.04),
//                             ),
//                             value: isSelected,
//                             onChanged: canSelect
//                                 ? (bool? value) {
//                               List<String> temp = List.from(adminController.getTempSelectedClasses(teacherId));
//                               if (value == true && temp.length < 2) {
//                                 temp.add(grade);
//                               } else if (value == false) {
//                                 temp.remove(grade);
//                               }
//                               adminController.setTempSelectedClasses(teacherId, temp);
//                             }
//                                 : null,
//                           );
//                         }).toList(),
//                       )),
//                     ),
//                     // Dialog actions
//                     actions: [
//                       GreenText(
//                         onTap: (){
//                           adminController.cancelDialogSelections(teacherId);
//                           Navigator.pop(context);
//                         },
//                         text: "Cancel",
//                         fontWeight: FontWeight.w700,
//                       ),
//                       SizedBox(width: screenWidth*.02,),
//                       GreenText(
//                         onTap: (){
//                           adminController.confirmDialogSelections(teacherId);
//                           Navigator.pop(context);
//                         },
//                         text: "Done",
//                         fontWeight: FontWeight.w700,
//                         textColor: Colors.green,
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Display selected classes or placeholder
//                 Expanded(
//                   child: Text(
//                     selectedGrades.isEmpty ? "Select Classes" : selectedGrades.join(", "),
//                     style: TextStyle(
//                       color: selectedGrades.isEmpty ? Colors.grey : Colors.black,
//                       fontSize: screenWidth * 0.04,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 // Dropdown icon
//                 Icon(
//                   Icons.arrow_drop_down,
//                   color: AppColors.darkBlue,
//                   size: screenWidth * 0.06,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }