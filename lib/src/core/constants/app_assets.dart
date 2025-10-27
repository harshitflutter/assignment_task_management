class AppAssets {
  static String lottieInternet = 'no_internet.json'.getLottiePath;
  static String icCheck = 'ic_check.svg';
}

extension AppAssetsExtension on String {
  String get getLottiePath => 'assets/lottie/$this';
}