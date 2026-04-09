import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/firestore_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLocalization BEFORE runApp
  await EasyLocalization.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load saved locale (defaults to English)
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('app_locale') ?? 'en';

  // Register core services as permanent singletons so they are NEVER
  // disposed by GetX during navigation.
  Get.put<FirestoreService>(FirestoreService(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(savedLang),
      child: const SavariiApp(),
    ),
  );
}

class SavariiApp extends StatelessWidget {
  const SavariiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Savarii',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      defaultTransition: Transition.fadeIn,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
