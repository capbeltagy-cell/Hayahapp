# Hayah AdMob and Google Play readiness

Current builds use Google's official Android test app/ad-unit IDs only.
Production configuration requires ADMOB_APP_ID, ADMOB_USE_PRODUCTION=true,
ADMOB_BANNER_ID, ADMOB_INTERSTITIAL_ID, ADMOB_REWARDED_ID, and
PRIVACY_POLICY_URL.

The only active placement is a reserved banner above the Home bottom
navigation. It never overlays content and is not present on Quran reading,
audio, prayer, Qibla, Hadith, or Fatwa screens. Interstitial support is
frequency limited and intentionally not connected to navigation. Rewarded
support is implemented but has no UI and gates no Islamic feature.

Before publishing, create the production AdMob app and consent messages, host
the real privacy policy, then review the app's actual behavior and the current
Google Mobile Ads SDK disclosure when completing Play Console Data Safety.
Complete Contains Ads, Content Rating, Target Audience, App Access,
countries/regions, and the store listing. Do not copy assumptions from this
document as legal declarations.

Permanent signing uses ANDROID_KEYSTORE_BASE64, ANDROID_KEY_ALIAS,
ANDROID_KEY_PASSWORD, and ANDROID_STORE_PASSWORD GitHub Secrets.
