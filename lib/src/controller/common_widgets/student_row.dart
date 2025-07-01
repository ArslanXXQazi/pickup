import '../../controller/constant/linkers/linkers.dart';
import '../../utills/app_loader.dart';
class StudentRow extends StatelessWidget {
  final VoidCallback ontap;
  final String studentName;
  final String? buttonText;
  final Color? textColor;
  final Color? buttonColor;
  final bool isLoading;

  StudentRow({
    super.key,
    required this.ontap,
    required this.studentName,
    this.textColor,
    this.buttonColor,
    this.buttonText,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth * 0.03;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 70,
              child: GreenText(
                text: studentName,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(width: basePadding * 0.125),
            Expanded(
              flex: 30,
              child: isLoading
                  ? AppLoader2()
                  : YellowButton(
                      onTap: ontap, // Fix: use actual callback
                      text: buttonText ?? "Not picked Up",
                      height: screenHeight * 0.05,
                      color: buttonColor ?? Colors.yellow,
                      textColor: textColor ?? AppColors.darkBlue,
                      borderRadius: screenWidth * 0.025,
                      fontSize: 12,
                    ),
            ),
          ],
        ),
        Divider(color: Colors.blue,),
      ],
    );
  }
}

