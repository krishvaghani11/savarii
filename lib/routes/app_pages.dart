import 'package:get/get.dart';
import 'package:savarii/features/auth/bindings/location_access_binding.dart';
import 'package:savarii/features/auth/bindings/otp_verification_binding.dart';
import 'package:savarii/features/auth/bindings/phone_login_binding.dart';
import 'package:savarii/features/auth/view/location_access_view.dart';
import 'package:savarii/features/auth/view/otp_verification_view.dart';
import 'package:savarii/features/auth/view/phone_login_view.dart';
import 'package:savarii/features/auth/view/role_selection_view.dart';
import 'package:savarii/features/customer/home/bindings/about_us_binding.dart';
import 'package:savarii/features/customer/home/bindings/book_parcel_binding.dart';
import 'package:savarii/features/customer/home/bindings/book_ticket_binding.dart';
import 'package:savarii/features/customer/home/bindings/bookings_binding.dart';
import 'package:savarii/features/customer/home/bindings/help_support_binding.dart';
import 'package:savarii/features/customer/home/bindings/language_binding.dart';
import 'package:savarii/features/customer/home/bindings/main_layout_binding.dart';
import 'package:savarii/features/customer/home/bindings/report_issue_binding.dart';
import 'package:savarii/features/customer/home/bindings/review_trip_binding.dart';
import 'package:savarii/features/customer/home/bindings/search_results_binding.dart';
import 'package:savarii/features/customer/home/bindings/seat_selection_binding.dart';
import 'package:savarii/features/customer/home/bindings/wallet_binding.dart';
import 'package:savarii/features/customer/home/view/about_us_view.dart';
import 'package:savarii/features/customer/home/view/book_parcel_view.dart';
import 'package:savarii/features/customer/home/view/book_ticket_view.dart';
import 'package:savarii/features/customer/home/view/bookings_view.dart';
import 'package:savarii/features/customer/home/view/help_support_view.dart';
import 'package:savarii/features/customer/home/view/language_view.dart';
import 'package:savarii/features/customer/home/view/main_layout_view.dart';
import 'package:savarii/features/customer/home/view/report_issue_view.dart';
import 'package:savarii/features/customer/home/view/review_trip_view.dart';
import 'package:savarii/features/customer/home/view/search_results_view.dart';
import 'package:savarii/features/customer/home/view/seat_selection_view.dart';
import 'package:savarii/features/customer/home/view/wallet_view.dart';
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
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.phoneLogin,
      page: () => const PhoneLoginView(),
      binding: PhoneLoginBinding(),
      transition: Transition.rightToLeft,
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
    // Added the missing Main Layout route
    GetPage(
      name: AppRoutes.customerMainLayout,
      page: () => const MainLayoutView(),
      binding: MainLayoutBinding(),
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: () => const HelpSupportView(),
      binding: HelpSupportBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.language,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () => const AboutUsView(),
      binding: AboutUsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.bookTicket,
      page: () => const BookTicketView(),
      binding: BookTicketBinding(),
      transition: Transition.rightToLeft, // Sleek side-to-side transition
    ),
    GetPage(
      name: AppRoutes.searchResults,
      page: () => const SearchResultsView(),
      binding: SearchResultsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.seatSelection,
      page: () => const SeatSelectionView(),
      binding: SeatSelectionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/wallet',
      page: () => const WalletView(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: '/bookings',
      page: () => const BookingsView(),
      binding: BookingsBinding(),
    ),
    GetPage(
      name: AppRoutes.bookParcel,
      page: () => const BookParcelView(),
      binding: BookParcelBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.reviewTrip,
      page: () => const ReviewTripView(),
      binding: ReviewTripBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.reportIssue,
      page: () => const ReportIssueView(),
      binding: ReportIssueBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
