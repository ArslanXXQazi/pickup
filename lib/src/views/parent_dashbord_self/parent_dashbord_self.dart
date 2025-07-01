import '../../controller/constant/linkers/linkers.dart';

class ParentDashBordSelf extends StatelessWidget {
  const ParentDashBordSelf({super.key});

  @override
  Widget build(BuildContext context) {
    /// Get screen dimensions for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03)
              .copyWith(top: screenHeight * 0.07),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// Logo Row with logo, title, and profile
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
                      fontSize: 30, // Font size unchanged
                      fontWeight: FontWeight.w700,
                    ),
                    const Spacer(),
                    ProfileContainer(),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                /// Parent Dashboard title
                GreenText(
                  text: "Parent Dashboard",
                  fontSize: 36, // Font size unchanged
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: screenHeight * 0.02),
                /// Arrived - Notify School container
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.015,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenHeight * 0.02),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ProfileContainer(),
                          SizedBox(width: screenWidth * 0.03),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GreenText(
                                text: "Student",
                                fontSize: 20, // Font size unchanged
                                fontWeight: FontWeight.w700,
                              ),
                              GreenText(
                                text: "Grade 3",
                                fontSize: 18, // Font size unchanged
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Expanded(
                            child: YellowButton(
                              onTap: () {},
                              text: "At school",
                              borderRadius: 20,
                              height: 40,
                              color: Colors.blue.shade50,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      YellowButton(
                        onTap: () {
                          Get.toNamed(AppRoutes.busDashBordView);
                        },
                        text: "I've Arrived - Notify School",
                        borderRadius: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                /// Track Pickup Cards Row
                Row(
                  children: [
                    /// Track Pickup card
                    Expanded(
                      child: PickUpTrackCard(
                        onTap: () {},
                        image: AppImages.location,
                        title: "Track Pickup",
                        description: "Waiting",
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    /// Pickup History card
                    Expanded(
                      child: PickUpTrackCard(
                        onTap: () {},
                        image: AppImages.clock,
                        title: "Pickup History",
                        description: "today 3:15 PM",
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    /// Notifications card
                    Expanded(
                      child: PickUpTrackCard(
                        onTap: () {},
                        image: AppImages.bell,
                        title: "Notifications",
                        description: "No notification from teacher yet",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                /// Help/FAQ button
                YellowButton(
                  onTap: () {},
                  text: "Help / FAQ",
                  color: Colors.white,
                  image: AppImages.help,
                  height: screenHeight * 0.05,
                ),
                SizedBox(height: screenHeight * 0.03),
                /// Pro tip text
                GreenText(
                  text: "Pro tip: The more Kids, the merrier (but we don't judge!)",
                  fontWeight: FontWeight.w400,
                  fontSize: 13, // Font size unchanged
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}