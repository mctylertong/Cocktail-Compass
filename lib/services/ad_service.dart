import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

/// Service for managing Google Mobile Ads
class AdService {
  static AdService? _instance;
  bool _isInitialized = false;

  AdService._();

  static AdService get instance {
    _instance ??= AdService._();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;

  /// Initialize the Mobile Ads SDK
  /// Call this once at app startup (in main.dart)
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;

    // Log if using test ads (helpful for debugging)
    if (AdConfig.isUsingTestAds) {
      print('AdService: Using TEST ad IDs - replace before publishing!');
    }
  }

  /// Create a banner ad with standard settings
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    void Function(Ad)? onAdOpened,
    void Function(Ad)? onAdClosed,
  }) {
    return BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: onAdOpened,
        onAdClosed: onAdClosed,
        onAdImpression: (ad) {
          // Ad impression recorded
        },
      ),
    );
  }
}
