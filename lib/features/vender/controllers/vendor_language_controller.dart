import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:shared_preferences/shared_preferences.dart';

class VendorLanguageController extends GetxController {
  // Reactive state for the selected language display name
  final RxString selectedLanguage = 'English'.obs;

  // Map from display name → locale code
  static const Map<String, String> _localeMap = {
    'English': 'en',
    'Gujarati': 'gu',
    'Hindi': 'hi',
  };

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  /// Load the previously saved locale on screen open
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('app_locale') ?? 'en';
    // Match language code back to display name
    final name = _localeMap.entries
        .firstWhere(
          (e) => e.value == savedCode,
          orElse: () => const MapEntry('English', 'en'),
        )
        .key;
    selectedLanguage.value = name;
  }

  void selectLanguage(String language) {
    selectedLanguage.value = language;
  }

  Future<void> saveLanguage() async {
    final langCode = _localeMap[selectedLanguage.value] ?? 'en';

    // Apply locale via EasyLocalization
    final context = Get.context;
    if (context != null) {
      await context.setLocale(Locale(langCode));
    }

    // Force GetX to rebuild views
    Get.updateLocale(Locale(langCode));

    // Persist user preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', langCode);

    Get.snackbar(
      'language.updated_title'.tr(),
      'language.updated_msg'.tr(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(seconds: 1), () => Get.back());
  }
}
