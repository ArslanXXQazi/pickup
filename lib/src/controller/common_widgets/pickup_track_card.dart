

import '../../controller/constant/linkers/linkers.dart';
class PickUpTrackCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final VoidCallback onTap;
  const PickUpTrackCard({super.key,
    required this.onTap,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.18,
        width: screenWidth * 0.35, // 150 -> relative to screen width
       // padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
              screenHeight * 0.012),
        ),
        child: Padding(
          padding:  EdgeInsets.only(top: screenHeight*.015),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.05, // 50 -> relative to screen height
                width: screenHeight * 0.05, // 50 -> relative to screen height
                child: ImageIcon(
                  AssetImage(image),
                  color: AppColors.yellowColor,
                ),
              ),
              // CircleAvatar(
              //   radius: 25,
              //   backgroundColor: Colors.blue.shade100,
              //   child: ImageIcon(
              //         AssetImage(image),
              //         color: AppColors.yellowColor,
              //       ),
              // ),
              SizedBox(height: screenHeight * 0.01),
              GreenText(
                text: title,
                fontWeight: FontWeight.w600,
                fontSize: 16, // Font size unchanged (default for GreenText)
              ),
              SizedBox(height: screenHeight * 0.005),
              GreenText(
                text: description,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
