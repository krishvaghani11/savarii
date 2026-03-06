import 'package:get/get.dart';
import 'package:savarii/features/auth/bindings/location_access_binding.dart';
import 'package:savarii/features/auth/bindings/otp_verification_binding.dart';
import 'package:savarii/features/auth/bindings/phone_login_binding.dart';
import 'package:savarii/features/auth/view/location_access_view.dart';
import 'package:savarii/features/auth/view/otp_verification_view.dart';
import 'package:savarii/features/auth/view/phone_login_view.dart';
import 'package:savarii/features/auth/view/role_selection_view.dart';
import 'package:savarii/features/splash/view/splash_view.dart';

import '../features/splash/bindings/splash_binding.dart';
import '../features/auth/bindings/role_selection_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    // Add the new Role Selection Route here:
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
      transition: Transition.fadeIn, // Smooth fade from the splash screen
    ),
    GetPage(
      name: AppRoutes.phoneLogin,
      page: () => const PhoneLoginView(),
      binding: PhoneLoginBinding(),
      transition: Transition
          .rightToLeft, // Standard horizontal slide for navigating deeper
    ),
    GetPage(
      name: AppRoutes.otpVerify,
      page: () => const OTPVerificationView(),
      binding: OTPVerificationBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.locationAccess,
      page: () => const LocationAccessView(),
      binding: LocationAccessBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
