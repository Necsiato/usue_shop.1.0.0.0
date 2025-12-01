class AppConfig {
  AppConfig._();

  static const String backendIp = '192.168.0.169';
  static const int backendPort = 8090;

  // Бренд проекта (перевод звучит по-русски)
  static const String brandTitle = 'Эвергрин Лабс';

  static const bool useBackend = true;
  static const bool allowInsecureCertificates = true;

  static String get baseUrl => 'http://$backendIp:$backendPort/api/v1/shop';
  static String get backendOrigin => 'http://$backendIp:$backendPort';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  // Base font size for the app UI.
  static const double baseFontSize = 15;
}
