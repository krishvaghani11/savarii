import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/add_passenger_controller.dart';


class CustomerAddPassengerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerAddPassengerController>(() => CustomerAddPassengerController());
  }
}