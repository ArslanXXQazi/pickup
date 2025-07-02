import 'package:pick_up_pal/src/utills/app_loader.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';

import '../../controller/constant/linkers/linkers.dart';

class LogInView extends StatelessWidget {
   LogInView({super.key});

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    /// Get screen dimensions for responsive design
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    /// Initialize text controllers for form fields
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final AuthController authController=Get.put(AuthController());

    return Scaffold(
      /// Set background color for the entire screen
      backgroundColor: Colors.blue.shade300,
      body: Stack(
        children: [
          /// Yellow background container
          Container(
            width: double.infinity,
            height: screenHeight * 0.45,
            decoration: BoxDecoration(
              color: AppColors.yellowColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(80),
                bottomLeft: Radius.circular(80),
              ),
            ),
          ),
          /// Main content
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.035,
                right: screenWidth * 0.035,
                top: screenHeight * 0.15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// Logo container with tracking icon
                  AppLogo(
                    height: screenHeight * 0.15,
                    width: screenWidth * 0.35,
                    iconSize: screenWidth * .25,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  /// App title
                  GreenText(
                    text: "PickUpPal",
                    fontSize: 35, // Font size unchanged
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Form(
                    key: formKey,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    /// Full Name text field
                    TextFieldWidget(
                      controller: authController.emailController,
                      hintText: "Email",
                      hintColor: Colors.blue,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    /// Email text field
                    TextFieldWidget(
                      controller: authController.passwordController,
                      hintText: "Password",
                      hintColor: Colors.blue,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a password";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],)),
                  /// Login button
                  Obx((){
                    return authController.isLoading.value?AppLoader2():
                    YellowButton(
                      onTap: () {
                        if(formKey.currentState!.validate()){
                          authController.logIn();
                        };
                      },


                      text: "Login",
                      borderColor: Colors.transparent,
                      borderRadius: 10,
                      fontSize: 20, // Font size unchanged
                    );
                  }),
                  SizedBox(height: screenHeight * 0.02),
                  /// Forgot Password text
                  GreenText(
                    onTap: () {
                      Get.toNamed(AppRoutes.forgotPassword);
                    },
                    text: "Forgot Password?",
                    fontSize: 18, // Font size unchanged
                    fontWeight: FontWeight.w400,
                    textColor: Colors.white,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  /// Sign Up prompt row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GreenText(
                        text: "Don't have an account?",
                        fontSize: 18, // Font size unchanged
                        fontWeight: FontWeight.w400,
                        textColor: Colors.white,
                      ),
                      GreenText(
                        onTap: () {
                          Get.toNamed(AppRoutes.signUpView);
                        },
                        text: "  Sign Up",
                        fontSize: 18, // Font size unchanged
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}