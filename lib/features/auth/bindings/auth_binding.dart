import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // AuthApiService, FirestoreService, and AuthController are permanent
    // singletons registered in main.dart — always available via Get.find().
  }
}
