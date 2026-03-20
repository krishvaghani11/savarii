import 'package:get/get.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/services/firestore_service.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApiService>(() => AuthApiService());
    Get.lazyPut<FirestoreService>(() => FirestoreService());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
