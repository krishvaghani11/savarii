import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Background / terminated message handler.
///
/// FCM rules:
///   - Must be a top-level function (not a class method).
///   - Must be annotated with @pragma('vm:entry-point').
///   - Firebase must be re-initialised in this isolate.
///
/// NOTE: No UI calls (Get.snackbar, Navigator, etc.) are allowed here.
/// Use this only for lightweight work such as local data logging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  debugPrint(
    'FCMHandler [BG]: type=${message.data['type']} '
    'title=${message.notification?.title}',
  );
  // Future: write to local DB / SharedPreferences for notification history.
}
