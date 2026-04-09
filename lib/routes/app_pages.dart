import 'package:get/get.dart';
import 'package:savarii/features/auth/bindings/customer_forgot_password_binding.dart';
import 'package:savarii/features/auth/bindings/customer_registration_binding.dart';
import 'package:savarii/features/auth/bindings/location_access_binding.dart';
import 'package:savarii/features/auth/bindings/customer%20_login_binding.dart';
import 'package:savarii/features/auth/view/customer_forgot_password_view.dart';
import 'package:savarii/features/auth/view/customer_registration_view.dart';
import 'package:savarii/features/auth/view/location_access_view.dart';
import 'package:savarii/features/auth/view/customer_login_view.dart';
import 'package:savarii/features/auth/view/role_selection_view.dart';
import 'package:savarii/features/customer/home/bindings/about_us_binding.dart';
import 'package:savarii/features/customer/home/bindings/book_parcel_binding.dart';
import 'package:savarii/features/customer/home/bindings/book_ticket_binding.dart';
import 'package:savarii/features/customer/home/bindings/booking_confirmation_binding.dart';
import 'package:savarii/features/customer/home/bindings/bookings_binding.dart';
import 'package:savarii/features/customer/home/bindings/customer_select_points_binding.dart';
import 'package:savarii/features/customer/home/bindings/edit_profile_binding.dart';
import 'package:savarii/features/customer/home/bindings/help_support_binding.dart';
import 'package:savarii/features/customer/home/bindings/language_binding.dart';
import 'package:savarii/features/customer/home/bindings/main_layout_binding.dart';
import 'package:savarii/features/customer/home/bindings/notification_settings_binding.dart';
import 'package:savarii/features/customer/home/bindings/parcel_confirmation_binding.dart';
import 'package:savarii/features/customer/home/bindings/parcel_payment_binding.dart';
import 'package:savarii/features/customer/home/bindings/payment_details_binding.dart';
import 'package:savarii/features/customer/home/bindings/privacy_policy_binding.dart';
import 'package:savarii/features/customer/home/bindings/privacy_settings_binding.dart';
import 'package:savarii/features/customer/home/bindings/report_issue_binding.dart';
import 'package:savarii/features/customer/home/bindings/review_trip_binding.dart';
import 'package:savarii/features/customer/home/bindings/search_results_binding.dart';
import 'package:savarii/features/customer/home/bindings/seat_selection_binding.dart';
import 'package:savarii/features/customer/home/bindings/security_settings_binding.dart';
import 'package:savarii/features/customer/home/bindings/settings_binding.dart';
import 'package:savarii/features/customer/home/bindings/terms_conditions_binding.dart';
import 'package:savarii/features/customer/home/bindings/track_bus_binding.dart';
import 'package:savarii/features/customer/home/bindings/wallet_binding.dart';
import 'package:savarii/features/customer/home/view/about_us_view.dart';
import 'package:savarii/features/customer/home/view/book_parcel_view.dart';
import 'package:savarii/features/customer/home/view/book_ticket_view.dart';
import 'package:savarii/features/customer/home/view/booking_confirmation_view.dart';
import 'package:savarii/features/customer/home/view/bookings_view.dart';
import 'package:savarii/features/customer/home/view/customer_select_points_view.dart';
import 'package:savarii/features/customer/home/view/edit_profile_view.dart';
import 'package:savarii/features/customer/home/view/help_support_view.dart';
import 'package:savarii/features/customer/home/view/language_view.dart';
import 'package:savarii/features/customer/home/view/main_layout_view.dart';
import 'package:savarii/features/customer/home/view/notification_settings_view.dart';
import 'package:savarii/features/customer/home/view/parcel_confirmation_view.dart';
import 'package:savarii/features/customer/home/view/parcel_payment_view.dart';
import 'package:savarii/features/customer/home/view/payment_details_view.dart';
import 'package:savarii/features/customer/home/view/privacy_policy_view.dart';
import 'package:savarii/features/customer/home/view/privacy_settings_view.dart';
import 'package:savarii/features/customer/home/view/report_issue_view.dart';
import 'package:savarii/features/customer/home/view/review_trip_view.dart';
import 'package:savarii/features/customer/home/view/search_results_view.dart';
import 'package:savarii/features/customer/home/view/seat_selection_view.dart';
import 'package:savarii/features/customer/home/view/security_settings_view.dart';
import 'package:savarii/features/customer/home/view/settings_view.dart';
import 'package:savarii/features/customer/home/view/terms_conditions_view.dart';
import 'package:savarii/features/customer/home/view/track_bus_view.dart';
import 'package:savarii/features/customer/home/view/wallet_view.dart';
import 'package:savarii/features/splash/view/splash_view.dart';
import 'package:savarii/features/vender/bindings/add_bus_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_add_travels_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_book_ticket_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_contact_developer_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_edit_profile_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_fleet_tracking_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_forgot_password_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_help_center_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_language_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_location_access_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_login_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_main_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_payment_confirmation_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_payment_details_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_privacy_policy_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_registration_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_settings_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_terms_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_travels_detail_binding.dart';
import 'package:savarii/features/vender/bindings/vendor_view_tickets_binding.dart';
import 'package:savarii/features/vender/view/add_bus_view.dart';
import 'package:savarii/features/vender/view/vendor_add_travels_view.dart';
import 'package:savarii/features/vender/view/vendor_book_ticket_view.dart';
import 'package:savarii/features/vender/view/vendor_contact_developer_view.dart';
import 'package:savarii/features/vender/view/vendor_edit_profile_view.dart';
import 'package:savarii/features/vender/view/vendor_fleet_tracking_view.dart';
import 'package:savarii/features/vender/view/vendor_forgot_password_view.dart';
import 'package:savarii/features/vender/view/vendor_help_center_view.dart';
import 'package:savarii/features/vender/view/vendor_language_view.dart';
import 'package:savarii/features/vender/view/vendor_location_access_view.dart';
import 'package:savarii/features/vender/view/vendor_login_view.dart';
import 'package:savarii/features/vender/view/vendor_main_view.dart';
import 'package:savarii/features/vender/view/vendor_payment_confirmation_view.dart';
import 'package:savarii/features/vender/view/vendor_payment_details_view.dart';
import 'package:savarii/features/vender/view/vendor_privacy_policy_view.dart';
import 'package:savarii/features/vender/view/vendor_registration_view.dart';
import 'package:savarii/features/vender/view/vendor_settings_view.dart';
import 'package:savarii/features/vender/view/vendor_terms_view.dart';
import 'package:savarii/features/vender/view/vendor_travels_detail_view.dart';
import 'package:savarii/features/vender/view/vendor_view_tickets_view.dart';
import 'package:savarii/features/vender/view/vendor_razorpay_view.dart';
import 'package:savarii/features/vender/bindings/vendor_razorpay_binding.dart';
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
      name: AppRoutes.customerLogin,
      page: () => const CustomerLoginView(),
      binding: CustomerLoginBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.locationAccess,
      page: () => const LocationAccessView(),
      binding: LocationAccessBinding(),
      transition: Transition.rightToLeft,
    ),
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
      transition: Transition.rightToLeft,
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
      name: AppRoutes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.myBookings,
      page: () => const BookingsView(),
      binding: BookingsBinding(),
      transition: Transition.rightToLeft,
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
    GetPage(
      name: '/edit-profile',
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsView(),
      binding: NotificationSettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.parcelPayment,
      page: () => const ParcelPaymentView(),
      binding: ParcelPaymentBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.parcelConfirmation,
      page: () => const ParcelConfirmationView(),
      binding: ParcelConfirmationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.paymentDetails,
      page: () => const PaymentDetailsView(),
      binding: PaymentDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.bookingConfirmation,
      page: () => const BookingConfirmationView(),
      binding: BookingConfirmationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.trackBus,
      page: () => const TrackBusView(),
      binding: TrackBusBinding(),
    ),
    GetPage(
      name: AppRoutes.privacySettings,
      page: () => const PrivacySettingsView(),
      binding: PrivacySettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.securitySettings,
      page: () => const SecuritySettingsView(),
      binding: SecuritySettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const TermsConditionsView(),
      binding: TermsConditionsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerSelectPoints,
      page: () => const CustomerSelectPointsView(),
      binding: CustomerSelectPointsBinding(),
      transition: Transition.rightToLeft,
    ),






    // vendor side routes
    GetPage(
      name: AppRoutes.vendorRegistration,
      page: () => const VendorRegistrationView(),
      binding: VendorRegistrationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorLogin,
      page: () => const VendorLoginView(),
      binding: VendorLoginBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorMain,
      page: () => const VendorMainView(),
      binding: VendorMainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.addBus,
      page: () => const AddBusView(),
      binding: AddBusBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorViewTickets,
      page: () => const VendorViewTicketsView(),
      binding: VendorViewTicketsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorBookTicket,
      page: () => const VendorBookTicketView(),
      binding: VendorBookTicketBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorPaymentDetails,
      page: () => const VendorPaymentDetailsView(),
      binding: VendorPaymentDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorPaymentConfirmation,
      page: () => const VendorPaymentConfirmationView(),
      binding: VendorPaymentConfirmationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorRazorpay,
      page: () => const VendorRazorpayView(),
      binding: VendorRazorpayBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorFleetTracking,
      page: () => const VendorFleetTrackingView(),
      binding: VendorFleetTrackingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorEditProfile,
      page: () => const VendorEditProfileView(),
      binding: VendorEditProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorAddTravels,
      page: () => const VendorAddTravelsView(),
      binding: VendorAddTravelsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorTravelsDetail,
      page: () => const VendorTravelsDetailView(),
      binding: VendorTravelsDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorSettings,
      page: () => const VendorSettingsView(),
      binding: VendorSettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorLanguage,
      page: () => const VendorLanguageView(),
      binding: VendorLanguageBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorContactDeveloper,
      page: () => const VendorContactDeveloperView(),
      binding: VendorContactDeveloperBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorHelpCenter,
      page: () => const VendorHelpCenterView(),
      binding: VendorHelpCenterBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorPrivacyPolicy,
      page: () => const VendorPrivacyPolicyView(),
      binding: VendorPrivacyPolicyBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorTerms,
      page: () => const VendorTermsView(),
      binding: VendorTermsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorLocationAccess,
      page: () => const VendorLocationAccessView(),
      binding: VendorLocationAccessBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.vendorForgotPassword,
      page: () => const VendorForgotPasswordView(),
      binding: VendorForgotPasswordBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerRegistration,
      page: () => const CustomerRegistrationView(),
      binding: CustomerRegistrationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerForgotPassword,
      page: () => const CustomerForgotPasswordView(),
      binding: CustomerForgotPasswordBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
