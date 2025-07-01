import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
class CustomDialogBox extends StatelessWidget {

  final String title;
  final String buttonName;
  final VoidCallback onTap;

   CustomDialogBox({super.key,
     required this.title,
     required this.buttonName,
     required this.onTap,
   });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return  AlertDialog(
      backgroundColor: Colors.white,
      title: GreenText(
        text: title,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      actions: [
        YellowButton(
          onTap: onTap,
          text: buttonName,
          color: Colors.red,
          textColor: Colors.white,
          borderRadius: 15,
          borderColor: Colors.transparent,
        ),
        SizedBox(height: screenHeight * .02),
        YellowButton(
          onTap: () { Get.back(); },
          text: "Go Back",
          color: Colors.blue,
          textColor: Colors.white,
          borderRadius: 15,
          borderColor: Colors.transparent,
        ),
      ],
    );
  }
}
