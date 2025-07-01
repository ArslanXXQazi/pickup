import '../../controller/constant/linkers/linkers.dart';
class NotificationWidget extends StatelessWidget {

  String title;
  String? message;
  String? message2;


   NotificationWidget({super.key,
     required this.title,
     this.message,
     this.message2,
   });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth * 0.03;
    return   Container(
      padding: EdgeInsets.symmetric(
        horizontal: basePadding * 0.5,
        vertical: basePadding * 0.9,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: screenWidth * 0.015,
            offset: Offset(0, screenWidth * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreenText(
            text: title,
            fontSize: 16, // Original font size
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: screenHeight * 0.02),
          GreenText(
            text: message,
            fontSize: 14, // Original font size
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: screenHeight * 0.01),
          GreenText(
            text: message2,
            fontSize: 14, // Original font size
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
