import '../../controller/constant/linkers/linkers.dart';

class DashbordForBusView extends StatelessWidget {
  const DashbordForBusView({super.key});

  @override
  Widget build(BuildContext context) {
    ///===========>> Getting screen dimensions using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      ///===========>> Dynamic gradient background
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          ///===========>> Padding for the main content
          padding: const EdgeInsets.only(left: 15, right: 15, top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///===========>> Welcome text for parent
              GreenText(
                text: "Welcome Parent",
                fontSize: screenHeight * 0.035, // Adjusted font size
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: screenHeight * 0.012),
              ///===========>> Student status container
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 15, vertical: screenHeight * 0.025),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///===========>> Student title
                    GreenText(
                      text: "Student",
                      fontSize: screenHeight * 0.025, // Adjusted font size
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    ///===========>> Student status row
                    Container(
                      height: screenHeight * 0.06,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFdeeff8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            ///===========>> Waiting for pickup text
                            GreenText(
                              text: "Waiting for pickup",
                              fontSize: screenHeight * 0.018, // Adjusted font size
                              fontWeight: FontWeight.w500,
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            ///===========>> Onboard button
                            Expanded(
                              child: YellowButton(
                                onTap: () {},
                                text: "Onboard",
                                borderColor: Colors.transparent,
                                borderRadius: 15,
                                color: AppColors.lightBlue,
                                textColor: AppColors.yellowColor,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            ///===========>> AT text
                            GreenText(
                              text: "AT ---",
                              fontSize: screenHeight * 0.018, // Adjusted font size
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.012),
              ///===========>> Bus details container
              BusDetailsWidget(onTap: () {
                Get.toNamed(AppRoutes.driverDashBordView);
              }, busNo: 7),
              SizedBox(height: screenHeight * 0.012),
              ///===========>> Row for history and map/quick actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ///===========>> Live location notification
                        HistoryNotificationWidget(
                          title: "Live Location",
                          description: "Your child boarded the bus at 7:43 am",
                          borderColor: Colors.blue,
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        ///===========>> Arrival notification
                        HistoryNotificationWidget(
                          title: "Notification",
                          description: "Your child arrived at 8:43 am",
                          borderColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: Column(
                      children: [
                        ///===========>> Map container
                        Container(
                          height: screenHeight * 0.22,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image(
                              image: AssetImage(AppImages.map),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),
                        ///===========>> Quick actions container
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(screenHeight * 0.018),
                            border: Border.all(color: Colors.blue),
                          ),
                          padding: EdgeInsets.all(screenHeight * 0.012),
                          child: Column(
                            children: [
                              ///===========>> Quick actions title
                              GreenText(
                                text: "Quick Actions",
                                fontWeight: FontWeight.w700,
                                fontSize: screenHeight * 0.025, // Adjusted font size
                              ),
                              SizedBox(height: screenHeight * 0.006),
                              ///===========>> Contact Driver button
                              YellowButton(
                                onTap: () {},
                                text: "Contact Driver",
                                color: AppColors.lightBlue,
                                borderRadius: screenHeight * 0.018,
                                textColor: Colors.white,
                              ),
                              SizedBox(height: screenHeight * 0.006),
                              ///===========>> Contact School Admin button
                              YellowButton(
                                onTap: () {},
                                text: "Contact School Admin",
                                color: AppColors.lightBlue,
                                borderRadius: screenHeight * 0.018,
                                textColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.012),
              ///===========>> Bus tracking help text
              GreenText(
                onTap: () {},
                text: "How does Bus Tracking Works?",
                fontWeight: FontWeight.w600,
                fontSize: screenHeight * 0.022, // Adjusted font size
              ),
            ],
          ),
        ),
      ),
    );
  }
}