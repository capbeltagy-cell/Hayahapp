import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

class RespectfulBannerAd extends StatefulWidget {
  const RespectfulBannerAd({super.key});

  @override
  State<RespectfulBannerAd> createState() => _RespectfulBannerAdState();
}

class _RespectfulBannerAdState extends State<RespectfulBannerAd> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    AdService.instance.adsReady.addListener(_loadIfReady);
    _loadIfReady();
  }

  void _loadIfReady() {
    if (!mounted || _banner != null || !AdService.instance.adsReady.value) {
      return;
    }
    final banner = AdService.instance.createBanner();
    if (banner != null) setState(() => _banner = banner);
  }

  @override
  void dispose() {
    AdService.instance.adsReady.removeListener(_loadIfReady);
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (banner == null) return const SizedBox.shrink();
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        width: double.infinity,
        height: banner.size.height.toDouble(),
        child: Center(
          child: SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ),
      ),
    );
  }
}
