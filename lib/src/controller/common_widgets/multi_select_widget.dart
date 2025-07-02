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

    // Grades list ke start mein 'None' option add karo (sirf admin/teacher mode)
    final List<String> gradesWithNone = isSingleSelection ? grades : ['None', ...grades];

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
                  // Admin/teacher mode ke liye assigned grades ka map le lo
                  Map<String, List<String>> assignedGradesMap = {};
                  if (!isSingleSelection && adminController != null) {
                    assignedGradesMap = Map<String, List<String>>.from(adminController.assignedGrades);
                  }
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: GreenText(
                      text: isSingleSelection ? "Select Grade" : "Select Classes (Max 2)",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    content: SizedBox(
                      height: screenHeight * 0.6,
                      width: screenWidth * 0.8,
                      child: ListView(
                        shrinkWrap: true,
                        children: gradesWithNone.map((grade) {
                          return Obx(() {
                            final isSelected = tempSelectedGrades.contains(grade);
                            final maxLimit = isSingleSelection ? 1 : 2;
                            final canSelect = tempSelectedGrades.length < maxLimit || isSelected;

                            // Roman Urdu: Check karo grade kisi aur teacher ko assign hai ya nahi
                            bool isAssignedToOther = false;
                            if (!isSingleSelection && teacherId != null && adminController != null && grade != 'None') {
                              assignedGradesMap.forEach((tid, clist) {
                                if (tid != teacherId && clist.contains(grade)) {
                                  isAssignedToOther = true;
                                }
                              });
                            }

                            // Agar 'None' select hai to baqi options disable kar do
                            final isNoneSelected = !isSingleSelection && tempSelectedGrades.contains('None');

                            // Agar grade kisi aur ko assign hai to disable karo aur (assigned) likho
                            return CheckboxListTile(
                              activeColor: AppColors.yellowColor,
                              tileColor: Colors.transparent,
                              title: Row(
                                children: [
                                  Text(
                                    grade,
                                    style: TextStyle(fontSize: screenWidth * 0.04),
                                  ),
                                  if (isAssignedToOther) ...[
                                    SizedBox(width: 8),
                                    Text(
                                      '(assigned)',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: screenWidth * 0.035,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              value: isSelected,
                              onChanged: (isAssignedToOther || !canSelect || isNoneSelected)
                                  ? null
                                  : (bool? value) {
                                // Agar koi class select ho to 'None' unselect ho jaye
                                if (!isSingleSelection && tempSelectedGrades.contains('None')) {
                                  tempSelectedGrades.remove('None');
                                }
                                if (isSingleSelection && value == true) {
                                  tempSelectedGrades.clear();
                                  tempSelectedGrades.add(grade);
                                } else if (!isSingleSelection && value == true && tempSelectedGrades.length < 2) {
                                  tempSelectedGrades.add(grade);
                                } else if (value == false) {
                                  tempSelectedGrades.remove(grade);
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
                            // Agar 'None' select hai to empty list assign karo
                            if (tempSelectedGrades.contains('None')) {
                              adminController!.setSelectedClasses(teacherId!, []);
                            } else {
                              adminController!.setSelectedClasses(teacherId!, tempSelectedGrades.toList());
                            }
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