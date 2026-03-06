// lib/core/constants/app_assets.dart

class AppAssets {
  // Prevent instantiation
  AppAssets._();

  // Root images directory
  static const String _imagesPath = 'assets/images';

  // Specific Asset Paths
  static const String mapBackgroundPattern = '$_imagesPath/bg_pattern.png';

  // Placeholder for your actual logo when you add it
  static const String savariiLogo = '$_imagesPath/bus.png';
  static const String otpShieldImage = '$_imagesPath/shield.png';

  // NEW ASSET
  static const String locationMapImage =
      '$_imagesPath/map.png'; // Update filename if needed
}
