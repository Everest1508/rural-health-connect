import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigService {
  static const String _baseUrlKey = 'api_base_url';
  static const String _groqApiKeyKey = 'groq_api_key';
  
  /// Get the stored base URL or return default
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUrl = prefs.getString(_baseUrlKey);
    
    if (storedUrl != null && storedUrl.isNotEmpty) {
      return storedUrl;
    }
    
    // Return default based on platform
    return _getDefaultBaseUrl();
  }
  
  /// Get default base URL based on platform
  static String _getDefaultBaseUrl() {
    // Production server URL
    return 'https://swasthsetu.pythonanywhere.com/api';
  }
  
  /// Save the base URL
  static Future<bool> setBaseUrl(String url) async {
    // Validate URL format
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      throw ArgumentError('URL must start with http:// or https://');
    }
    
    // Remove trailing slash if present
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_baseUrlKey, cleanUrl);
  }
  
  /// Reset to default base URL
  static Future<bool> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_baseUrlKey);
  }
  
  /// Get current base URL (synchronous for ApiClient initialization)
  static String getCurrentBaseUrl() {
    // This is a fallback - ApiClient should use getBaseUrl() async method
    return _getDefaultBaseUrl();
  }
  
  /// Get the stored Groq API key
  static Future<String?> getGroqApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_groqApiKeyKey);
  }
  
  /// Save the Groq API key
  static Future<bool> setGroqApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_groqApiKeyKey, apiKey.trim());
  }
  
  /// Remove the Groq API key
  static Future<bool> removeGroqApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_groqApiKeyKey);
  }
}

