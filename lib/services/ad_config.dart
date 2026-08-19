import 'package:flutter/foundation.dart';

class AdConfig {
  const AdConfig._();

  static const bool useProduction = bool.fromEnvironment(
    'ADMOB_USE_PRODUCTION',
    defaultValue: false,
  );

  static const String _productionBannerId =
      String.fromEnvironment('ADMOB_BANNER_ID');
  static const String _productionInterstitialId =
      String.fromEnvironment('ADMOB_INTERSTITIAL_ID');
  static const String _productionRewardedId =
      String.fromEnvironment('ADMOB_REWARDED_ID');
  static const String privacyPolicyUrl =
      String.fromEnvironment('PRIVACY_POLICY_URL');

  static const String _testBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  static String get bannerId => useProduction ? 'ca-app-pub-4693639798724853/4349216181' : _testBannerId;
  static String get interstitialId => useProduction
      ? _required(_productionInterstitialId, 'ADMOB_INTERSTITIAL_ID')
      : _testInterstitialId;
  static String get rewardedId => useProduction
      ? _required(_productionRewardedId, 'ADMOB_REWARDED_ID')
      : _testRewardedId;

  static bool get isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String _required(String value, String name) {
    if (value.isEmpty) {
      throw StateError('$name is required when ADMOB_USE_PRODUCTION=true');
    }
    return value;
  }
}

