import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pick_up_pal/firebase_options.dart';
import 'package:pick_up_pal/src/controller/common_widgets/app_logo.dart';
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/routes/app_routes.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_dashBord_view.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/view_all_parents/view_all_parents.dart';
import 'package:pick_up_pal/src/views/auth_views/log_in_view.dart';
import 'package:pick_up_pal/src/views/auth_views/sign_up_view.dart';
import 'package:pick_up_pal/src/views/auth_views/user_id.dart';
import 'package:pick_up_pal/src/views/dashbord_for_bus_view/dashbord_for_bus_view.dart';
import 'package:pick_up_pal/src/views/driver_dashbord_view/driver_dashbord_view.dart';
import 'package:pick_up_pal/src/views/help_faq_view/help_faq_view.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/parent_dashbord.dart';
import 'package:pick_up_pal/src/views/parent_dashbord_self/parent_dashbord_self.dart';
import 'package:pick_up_pal/src/views/starting_view/wellcome_view.dart';
import 'package:pick_up_pal/src/views/teacher_dashbord_view/teacher_dashbord_view.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(UserId());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      // home:  ViewAllParents(),
      //HelpFaqView(),
      //SplashView()
      //AdminDashbordView(),
     // DriverDashBordView(),
    //SplashView(),
        //WelcomeView(),
    //LogInView(),
     // SignUpView(),
     // TeacherDashbordView(),
      //ParentDashBordSelf(),
      //ParentDashbord(),
    );
  }
}
