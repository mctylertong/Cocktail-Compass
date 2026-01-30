import 'dart:io';

/// AdMob Configuration
///
/// IMPORTANT: Replace these test IDs with your real AdMob IDs before publishing!
///
/// To get your real IDs:
/// 1. Go to https://admob.google.com/
/// 2. Create an account and add your app
/// 3. Create ad units for each ad type you want
/// 4. Copy the App ID and Ad Unit IDs here
///
/// Test IDs are provided by Google for development - they show test ads
/// and won't generate revenue, but won't get your account banned either.

class AdConfig {
  // ============================================================
  // APP IDs - Replace with your real App IDs from AdMob
  // ============================================================

  /// Android App ID (from AdMob console)
  /// Test ID: ca-app-pub-3940256099942544~3347511713
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';

  /// iOS App ID (from AdMob console)
  /// Test ID: ca-app-pub-3940256099942544~1458002511
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  // ============================================================
  // BANNER AD UNIT IDs - Replace with your real Ad Unit IDs
  // ============================================================

  /// Android Banner Ad Unit ID
  /// Test ID: ca-app-pub-3940256099942544/6300978111
  static const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  /// iOS Banner Ad Unit ID
  /// Test ID: ca-app-pub-3940256099942544/2934735716
  static const String iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

  // ============================================================
  // HELPER GETTERS
  // ============================================================

  /// Get the appropriate App ID for the current platform
  static String get appId {
    if (Platform.isAndroid) {
      return androidAppId;
    } else if (Platform.isIOS) {
      return iosAppId;
    }
    throw UnsupportedError('Unsupported platform for ads');
  }

  /// Get the appropriate Banner Ad Unit ID for the current platform
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return iosBannerAdUnitId;
    }
    throw UnsupportedError('Unsupported platform for ads');
  }

  /// Check if we're using test ads (for debugging)
  static bool get isUsingTestAds {
    return androidAppId.contains('3940256099942544') ||
        iosAppId.contains('3940256099942544');
  }
}
