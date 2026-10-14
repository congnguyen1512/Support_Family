class ApiConstants {
  const ApiConstants._();

  static const String baseUrlDefineKey = 'FAMILY_GUARD_API_BASE_URL';
  static const String localhostBaseUrl = 'http://127.0.0.1:3000/api';
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:3000/api';
  static const String androidUsbDebugBaseUrl = localhostBaseUrl;

  static const Duration requestTimeout = Duration(seconds: 15);
  static const Duration locationTrackingInterval = Duration(seconds: 60);
}
