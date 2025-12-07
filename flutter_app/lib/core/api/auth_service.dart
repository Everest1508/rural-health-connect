import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../utils/error_handler.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    required String phone,
    required String location,
  }) async {
    try {
      final response = await _api.post('/auth/register/', data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'location': location,
      });
      
      if (response.statusCode == 201) {
        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response.data['tokens']['access']);
        await prefs.setString('refresh_token', response.data['tokens']['refresh']);
        
        // Save user data
        final user = response.data['user'];
        await prefs.setString('userName', '${user['first_name']} ${user['last_name']}');
        await prefs.setString('userEmail', user['email']);
        await prefs.setString('userPhone', user['phone'] ?? '');
        await prefs.setString('userLocation', user['location'] ?? '');
        
        return {'success': true, 'user': user, 'tokens': response.data['tokens']};
      }
      throw Exception('Registration failed');
    } catch (e) {
      return {'success': false, 'error': ErrorHandler.getErrorMessage(e)};
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login/', data: {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response.data['access']);
        await prefs.setString('refresh_token', response.data['refresh']);
        
        // Save user data
        final user = response.data['user'];
        await prefs.setString('userName', user['full_name'] ?? '${user['first_name']} ${user['last_name']}');
        await prefs.setString('userEmail', user['email']);
        await prefs.setString('userPhone', user['phone'] ?? '');
        await prefs.setString('userLocation', user['location'] ?? '');
        
        return {'success': true, 'user': user};
      }
      throw Exception('Login failed');
    } catch (e) {
      return {'success': false, 'error': ErrorHandler.getErrorMessage(e)};
    }
  }
  
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _api.get('/auth/profile/');
      if (response.statusCode == 200) {
        return {'success': true, 'user': response.data};
      }
      throw Exception('Failed to get profile');
    } catch (e) {
      return {'success': false, 'error': ErrorHandler.getErrorMessage(e)};
    }
  }
  
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? location,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (location != null) data['location'] = location;
      
      final response = await _api.put('/auth/profile/', data: data);
      if (response.statusCode == 200) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        final user = response.data['user'];
        await prefs.setString('userName', user['full_name']);
        if (user['phone'] != null) await prefs.setString('userPhone', user['phone']);
        if (user['location'] != null) await prefs.setString('userLocation', user['location']);
        
        return {'success': true, 'user': user};
      }
      throw Exception('Failed to update profile');
    } catch (e) {
      return {'success': false, 'error': ErrorHandler.getErrorMessage(e)};
    }
  }
  
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout/');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      await prefs.remove('userPhone');
      await prefs.remove('userLocation');
    }
  }
}

