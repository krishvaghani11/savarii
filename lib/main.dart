import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  // Ensures Flutter engine is fully initialized before the app runs.
  // Required for GetX routing and future Firebase initialization.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SavariiApp());
}

class SavariiApp extends StatelessWidget {
  const SavariiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Savarii',
      debugShowCheckedModeBanner: false,
      // Removes the red debug banner

      // Global Theme applying your custom #2B2D42 and #EF233C colors
      theme: AppTheme.lightTheme,
      defaultTransition: Transition.fadeIn,

      // GetX Routing Setup starting with the Splash Screen
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
