import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  ApiConfig._();

  static const String defaultBaseUrl = 'http://10.0.2.2:3001';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('serverIp') ?? '';
    final port = prefs.getString('serverPort') ?? '';

    if (ip.isNotEmpty && port.isNotEmpty) {
      return 'http://$ip:$port';
    }
    return defaultBaseUrl;
  }
}
