import 'package:get/get.dart';
import 'package:savarii/core/services/bus_search_service.dart';
import 'package:savarii/features/customer/home/controller/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    // Register BusSearchService as a GetxService (singleton)
    // This should be done in main.dart during app initialization as a permanent service
    // But we'll also ensure it's available here
    if (!Get.isRegistered<BusSearchService>()) {
      Get.put(BusSearchService(), permanent: true);
    }

    // Register SearchController
    Get.lazyPut<SearchController>(() => SearchController());
  }
}

