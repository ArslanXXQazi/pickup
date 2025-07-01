import 'package:flutter/material.dart';
import '../../controller/constant/linkers/linkers.dart';

class HelpFaqView extends StatelessWidget {
  const HelpFaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.yellowColor,
        title: GreenText(
          text: "Help & FAQ",
          fontSize: 24,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.start,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreenText(
              text: "Help and FAQ",
              fontSize: 20,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 16),
            GreenText(
              text:
              "Welcome to PickUpPal! Below are answers to common questions to help you get started and make the most of our smart school pickup system.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 24),
            // General FAQs
            GreenText(
              text: "General Questions",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: GreenText(
                text: "What is PickUpPal?",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.start,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GreenText(
                    text:
                    "PickUpPal is a mobile app that simplifies and secures the school pickup process. It connects parents, drivers, and school staff in real-time to ensure safe and efficient pickups.",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: GreenText(
                text: "How do I get started?",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.start,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GreenText(
                    text:
                    "1. Download PickUpPal from the App Store or Google Play.\n2. Sign up with your email and select your role (Parent, Driver, Teacher, or Admin).\n3. Complete your profile and link your account to your school.\n4. Start using the app to track pickups or manage students!",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Parent FAQs
            GreenText(
              text: "For Parents",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: GreenText(
                text: "How do I track the driver?",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.start,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GreenText(
                    text:
                    "From the Parent Dashboard, go to the 'Track Pickup' section. You'll see a real-time map showing the driver's location as they approach the school.",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: GreenText(
                text: "What happens if the driver is late?",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.start,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GreenText(
                    text:
                    "You'll receive a notification if the driver is delayed. You can also contact the driver directly through the app's chat feature.",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Driver FAQs
            GreenText(
              text: "For Drivers",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: GreenText(
                text: "How do I notify parents of my arrival?",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.start,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GreenText(
                    text:
                    "From the Driver Dashboard, select the assigned student and tap 'Notify Arrival'. This sends a real-time alert to the parent.",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Teacher FAQs
            GreenText(
              text: "For Teachers/School Staff",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: GreenText(
                text: "How do I confirm a pickup?",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.start,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GreenText(
                    text:
                    "From the Teacher Dashboard, select the student and verify the driver's identity. Tap 'Confirm Pickup' to mark the student as safely picked up.",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Admin FAQs
            GreenText(
              text: "For Admins",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: GreenText(
                text: "How do I add a new school to PickUpPal?",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.start,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GreenText(
                    text:
                    "From the Admin Dashboard, go to 'School Management' and select 'Add School'. Enter the school details and assign teachers or drivers as needed.",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Contact Support
            GreenText(
              text: "Still Need Help?",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            GreenText(
              text:
              "Contact our support team at support@pickuppal.com or call us at +92-300-1234567. We're here to assist you!",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}