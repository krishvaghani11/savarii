import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/firebase_options.dart';
import 'core/services/firestore_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register core services as permanent singletons so they are NEVER
  // disposed by GetX during navigation. This ensures AuthController.uid
  // (set during OTP login) is preserved all the way to the Add Bus screen.
  Get.put<FirestoreService>(FirestoreService(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);

  runApp(const SavariiApp());
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
    );
  }
}
