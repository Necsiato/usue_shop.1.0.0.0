class AppConfig {
  AppConfig._();

  static const String backendIp = '192.168.0.169';
  static const int backendPort = 8090;

  static const bool useBackend = true;
  static const bool allowInsecureCertificates = true;

  static String get baseUrl => 'http://$backendIp:$backendPort/api/v1/shop';
  static String get backendOrigin => 'http://$backendIp:$backendPort';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  static const double baseFontSize = 14;
}
