import '../../controller/constant/linkers/linkers.dart';
class AddChildCard extends StatelessWidget {
  final VoidCallback onTap;
  const AddChildCard({super.key,required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SizedBox(
          height: screenHeight * 0.31,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: screenHeight * 0.26,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      screenHeight * 0.02), // 20 -> relative
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: screenHeight * 0.015),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GreenText(
                        text: "Add Child",
                        fontSize: 39, // Font size unchanged
                        fontWeight: FontWeight.w700,
                      ),
                      GreenText(
                        text:
                        "Add a child to activates these features",
                        fontSize: 16, // Font size unchanged
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      YellowButton(
                        onTap: onTap,
                        width: screenWidth * 0.6, // 250 -> relative to screen width
                        text: "Add Child",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: CircleAvatar(
            radius: screenHeight * 0.04, // 35 -> relative to screen height
            backgroundColor: Colors.blue.shade200,
            child: Icon(
              Icons.person,
              size: screenHeight * 0.06, // 50 -> relative to screen height
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
