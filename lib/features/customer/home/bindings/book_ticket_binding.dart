import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/book_ticket_controller.dart';

class BookTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookTicketController>(() => BookTicketController());
  }
}
