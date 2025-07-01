import 'package:pick_up_pal/src/controller/common_widgets/custom_dialog_box.dart';
import 'package:pick_up_pal/src/views/auth_views/auth_controller.dart';
import 'package:pick_up_pal/src/controller/common_widgets/text_field_widget.dart';
import 'package:pick_up_pal/src/controller/common_widgets/button_widget.dart';
import 'package:get/get.dart';
import '../../utills/app_loader.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/utills/snackbar.dart';

class DriverProfileView extends StatefulWidget {
  const DriverProfileView({super.key});

  @override
  State<DriverProfileView> createState() => _DriverProfileViewState();
}

class _DriverProfileViewState extends State<DriverProfileView> {
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    authController.initProfileFields();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: ProfileContainer(radius: screenWidth * 0.13)),
              SizedBox(height: screenHeight * 0.03),
              TextFieldWidget(
                controller: authController.profileNameController,
                hintText: 'Your Name',
                prefixIcon: Icon(Icons.person, color: AppColors.darkBlue),
              ),
              SizedBox(height: screenHeight * 0.025),
              TextFieldWidget(
                controller: authController.profileAddressController,
                hintText: 'Address',
                prefixIcon: Icon(Icons.location_on, color: AppColors.darkBlue),
              ),
              SizedBox(height: screenHeight * 0.025),
              TextFieldWidget(
                controller: authController.profileEmailController,
                hintText: 'Email',
                prefixIcon: Icon(Icons.email, color: AppColors.darkBlue),
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              SizedBox(height: screenHeight * 0.025),
              TextFieldWidget(
                controller: authController.profilePhoneController,
                hintText: 'Phone',
                prefixIcon: Icon(Icons.phone, color: AppColors.darkBlue),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: screenHeight * 0.03),
              Obx(() => authController.isLoading.value
                  ? const AppLoader2()
                  : YellowButton(
                text: 'Save',
                onTap: () async {
                  await authController.saveProfile(
                    nameController: authController.profileNameController,
                    emailController: authController.profileEmailController,
                    addressController: authController.profileAddressController,
                    phoneController: authController.profilePhoneController,
                  );
                },
                borderRadius: 15,
                borderColor: Colors.transparent,
              )),
              SizedBox(height: screenHeight * 0.025),
              YellowButton(
                text: 'Logout',
                onTap: () {
                  Get.dialog(
                    CustomDialogBox(
                      buttonName: "Log Out",
                      title: "Are you sure you want to logout?",
                      onTap: () {
                        authController.logout();
                      },
                    ),
                  );
                },
                borderRadius: 15,
                borderColor: Colors.transparent,
                color: Colors.red.shade400,
                textColor: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                image: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}