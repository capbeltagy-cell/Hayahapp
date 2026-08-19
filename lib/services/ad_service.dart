import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class AdService {
  AdService._();

  static final AdService instance = AdService._();

  final ValueNotifier<bool> adsReady = ValueNotifier<bool>(false);
  final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier<bool>(false);

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  DateTime? _lastInterstitialAt;
  int _eligibleTransitions = 0;
  bool _initialized = false;
  bool _initializing = false;

  static const Duration _minimumInterstitialInterval = Duration(minutes: 5);
  static const int _minimumEligibleTransitions = 4;

  Future<void> initialize() async {
    if (_initialized || _initializing || !AdConfig.isSupportedPlatform) return;
    _initializing = true;
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) debugPrint('UMP form error: ${error.message}');
        });
        await _refreshPrivacyOptions();
        if (await ConsentInformation.instance.canRequestAds()) {
          await _initializeAds();
        }
        if (!completer.isCompleted) completer.complete();
      },
      (error) async {
        debugPrint('UMP update error: ${error.message}');
        await _refreshPrivacyOptions();
        if (await ConsentInformation.instance.canRequestAds()) {
          await _initializeAds();
        }
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
    _initializing = false;
  }

  Future<void> _initializeAds() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    adsReady.value = true;
    _loadInterstitial();
    _loadRewarded();
  }

  Future<void> _refreshPrivacyOptions() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    privacyOptionsRequired.value =
        status == PrivacyOptionsRequirementStatus.required;
  }

  void showPrivacyOptions() {
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('UMP privacy error: ${error.message}');
    });
  }

  BannerAd? createBanner() {
    if (!_initialized) return null;
    return BannerAd(
      adUnitId: AdConfig.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  void _loadInterstitial() {
    return; // Disabled: Hayah uses banner ads only
    if (!_initialized || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial load error: ${error.message}');
          _interstitial = null;
        },
      ),
    );
  }

  // Intentionally not called by navigation. Available only for a future,
  // explicitly eligible non-Quran transition.
  void recordEligibleTransitionAndMaybeShow() {
    _eligibleTransitions++;
    final now = DateTime.now();
    final intervalPassed =
        _lastInterstitialAt == null ||
        now.difference(_lastInterstitialAt!) >= _minimumInterstitialInterval;
    final ad = _interstitial;
    if (_eligibleTransitions < _minimumEligibleTransitions ||
        !intervalPassed ||
        ad == null) {
      _loadInterstitial();
      return;
    }
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    _eligibleTransitions = 0;
    _lastInterstitialAt = now;
    ad.show();
  }

  void _loadRewarded() {
    return; // Disabled: Hayah uses banner ads only
    if (!_initialized || _rewarded != null) return;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded load error: ${error.message}');
          _rewarded = null;
        },
      ),
    );
  }

  bool showRewarded({required void Function(RewardItem reward) onReward}) {
    return false; // Disabled: Hayah uses banner ads only
    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    _rewarded = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewarded();
      },
    );
    ad.show(onUserEarnedReward: (_, reward) => onReward(reward));
    return true;
  }
}
