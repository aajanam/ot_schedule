import 'dart:io';

class AdMobService {

  String getAdMobAppId() {
    if (Platform.isIOS) {
      return null;
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-7716978148792169~3665684510';
    }
    return null;
  }

  String getBannerAdId() {
    if (Platform.isIOS) {
      return null;
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-7716978148792169/8246753896';
    }
    return null;
  }

}