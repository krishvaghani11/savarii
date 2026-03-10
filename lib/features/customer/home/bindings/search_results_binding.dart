import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/search_results_controller.dart';

class SearchResultsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchResultsController>(() => SearchResultsController());
  }
}
