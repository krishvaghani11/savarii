import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/report_issue_controller.dart';

class ReportIssueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportIssueController>(() => ReportIssueController());
  }
}
