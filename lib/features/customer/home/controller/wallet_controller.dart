import 'package:get/get.dart';

class WalletController extends GetxController {
  // Dummy Balance
  final RxDouble currentBalance = 450.00.obs;

  // Dummy Transactions List
  final RxList<Map<String, dynamic>> recentTransactions = [
    {
      'id': 't1',
      'title': 'Ride to Airport',
      'date': 'Today, 10:23 AM',
      'status': 'Completed',
      'amount': '- ₹350.00',
      'isCredit': false,
      'iconType': 'ride', // Used to determine which icon to show
    },
    {
      'id': 't2',
      'title': 'Wallet Top-up',
      'date': 'Yesterday, 06:45 PM',
      'status': 'Success',
      'amount': '+ ₹800.00',
      'isCredit': true,
      'iconType': 'wallet',
    },
    {
      'id': 't3',
      'title': 'Parcel Delivery',
      'date': '20 Oct, 02:15 PM',
      'status': 'Completed',
      'amount': '- ₹120.00',
      'isCredit': false,
      'iconType': 'parcel',
    },
    {
      'id': 't4',
      'title': 'Office Commute',
      'date': '19 Oct, 09:00 AM',
      'status': 'Completed',
      'amount': '- ₹85.00',
      'isCredit': false,
      'iconType': 'ride',
    },
  ].obs;

  void addMoney() {
    print("Navigating to Add Money flow...");
  }

  void transferMoney() {
    print("Navigating to Transfer flow...");
  }

  void scanQR() {
    print("Opening QR Scanner...");
  }

  void manageCards() {
    print("Navigating to Saved Cards...");
  }

  void viewRewards() {
    print("Navigating to Rewards...");
  }

  void moreOptions() {
    print("Opening More Wallet Options...");
  }

  void viewAllTransactions() {
    print("Opening Full Transaction History...");
  }
}
