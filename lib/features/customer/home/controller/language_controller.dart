import 'package:get/get.dart';

class LanguageController extends GetxController {
  // Reactive variable to hold the selected language code
  // Defaulting to English ('en')
  final RxString selectedLanguage = 'en'.obs;

  void selectLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
  }

  void saveAndContinue() {
    print("Saving language preference: ${selectedLanguage.value}");
    // TODO: Actually change the app's locale using Get.updateLocale() later

    // Navigate back to the previous screen (Dashboard)
    Get.back();

    Get.snackbar(
      'Language Updated',
      'Your preferred language has been set successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
