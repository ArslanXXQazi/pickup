
import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/all_child_detail/all_child_detail.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/view_all_parents/view_all_parents.dart';
import 'package:pick_up_pal/src/views/auth_views/forgot_password_view.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/add_child_view/add_child_view.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/add_child_view/view_all_child.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/add_users/add_users_view.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/admin_dashBord_view.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/assign_bus/assign_bus_view.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/assign_classes/assign_classes.dart';
import 'package:pick_up_pal/src/views/admin_dashBoard_view/manage_user/manage_user_view.dart';
import 'package:pick_up_pal/src/views/auth_views/log_in_view.dart';
import 'package:pick_up_pal/src/views/auth_views/sign_up_view.dart';
import 'package:pick_up_pal/src/views/dashbord_for_bus_view/dashbord_for_bus_view.dart';
import 'package:pick_up_pal/src/views/driver_dashbord_view/driver_dashbord_view.dart';
import 'package:pick_up_pal/src/views/driver_dashbord_view/driver_profile_view.dart';
import 'package:pick_up_pal/src/views/help_faq_view/help_faq_view.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/parent_dashbord.dart';
import 'package:pick_up_pal/src/views/parent_dashbord_self/parent_dashbord_self.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/pickup_history/pickup_history.dart';
import 'package:pick_up_pal/src/views/parent_dashbord/pickup_notification/pickup_notification.dart';
import 'package:pick_up_pal/src/views/starting_view/splash_view.dart';
import 'package:pick_up_pal/src/views/starting_view/wellcome_view.dart';
import 'package:pick_up_pal/src/views/teacher_dashbord_view/teacher_dashbord_view.dart';
import 'package:pick_up_pal/src/views/track_pickup/track_pickup.dart';

class AppRoutes{

  static String   splash ='/';
  static String   welcomeView ='/welcomeView';
  static String   signUpView ='/signUpView';
  static String   loginView ='/loginView';
  static String   parentDashBord ='/parentDashBord';
  static String   parentDashBordSelf ='/parentDashBordSelf';
  static String   teacherDashBord ='/teacherDashBord';
  static String   busDashBordView ='/busDashBordView';
  static String   driverDashBordView ='/driverDashBordView';
  static String   adminView ='/adminView';
  static String   manageUserView ='/manageUserView';
  static String   addChildView ='/addChildView';
  static String   viewAllChild ='/viewAllChild';
  static String   pickUpHistory ='/pickUpHistory';
  static String   pickUpNotification ='/pickUpNotification';
  static String   trackPickup ='/trackPickup';
  static String   helpAndFaq ='/helpAndFaq';
  static String   driverProfileView ='/driverProfileView';
  static String   addUsersView ='/addUsersView';
  static String   assignBussesView ='/assignBussesView';
  static String   assignClassesView ='/assignClassesView';
  static String   viewAllParents ='/viewAllParents';
  static String   forgotPassword ='/forgotPassword';
 static  String   allChildDetail='/allChildDetail';


  static final routes=
  [

    GetPage(
      name: splash,
      page: ()=>SplashView(),
    ),

    GetPage(
      name: welcomeView,
      page: ()=>WelcomeView(),
    ),

    GetPage(
      name: signUpView,
      page: ()=>SignUpView(),
    ),

    GetPage(
      name: loginView,
      page: ()=>LogInView(),
    ),

    GetPage(
      name: parentDashBord,
      page: ()=>ParentDashbord(),
    ),

    GetPage(
      name: parentDashBordSelf,
      page: ()=>ParentDashBordSelf(),
    ),

    GetPage(
      name: teacherDashBord,
      page: ()=>TeacherDashbordView(),
    ),

    GetPage(
      name: busDashBordView,
      page: ()=>DashbordForBusView(),
    ),

    GetPage(
      name: driverDashBordView,
      page: ()=>DriverDashBordView(),
    ),

    GetPage(
      name: adminView,
      page: ()=>AdminDashbordView(),
    ),

    GetPage(
      name: manageUserView,
      page: ()=>ManageUserView(),
    ),

    GetPage(
      name: addChildView,
      page: ()=>AddChildView(),
    ),

    GetPage(
      name: viewAllChild,
      page: ()=>ViewAllChild(),
    ),

    GetPage(
      name: pickUpHistory,
      page: ()=>PickupHistory(),
    ),

    GetPage(
      name: pickUpNotification,
      page: ()=>PickupNotification()),

    GetPage(
      name: trackPickup,
      page: ()=>TrackPickup()),

    GetPage(
      name: helpAndFaq,
      page: ()=>HelpFaqView()),

    GetPage(
      name: driverProfileView,
      page: ()=>DriverProfileView()),

    GetPage(
      name: addUsersView,
      page: ()=>AddUserView()),

    GetPage(
      name: assignBussesView,
      page: ()=>AssignBusView()),

    GetPage(
      name: assignClassesView,
      page: ()=>AssignClasses()),
    
    GetPage(
      name: viewAllParents,
      page: ()=>ViewAllParents()),

    GetPage(
      name: forgotPassword,
      page: ()=>ForgotPasswordView()),

      GetPage(
      name: allChildDetail,
      page: ()=>AllChildDetail()),


  ];
}