import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/auth_service.dart';

class AppState extends ChangeNotifier {
  // Authentication state
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Theme mode
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Current user info
  String _userName = 'Ram Singh';
  String _userLocation = 'Nabha, Punjab';
  String _userEmail = '';
  String _userPhone = '';
  bool _isDoctor = false;
  bool _isPharmacist = false;

  String get userName => _userName;
  String get userLocation => _userLocation;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  bool get isDoctor => _isDoctor;
  bool get isPharmacist => _isPharmacist;

  AppState() {
    _loadAuthState();
    _loadThemeState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userName = prefs.getString('userName')?.trim() ?? 'User';
    if (_userName.isEmpty) _userName = 'User';
    _userLocation = prefs.getString('userLocation')?.trim() ?? 'Location';
    if (_userLocation.isEmpty) _userLocation = 'Location';
    _userEmail = prefs.getString('userEmail')?.trim() ?? '';
    _userPhone = prefs.getString('userPhone')?.trim() ?? '';
    _isDoctor = prefs.getBool('isDoctor') ?? false;
    _isPharmacist = prefs.getBool('isPharmacist') ?? false;
    notifyListeners();
  }

  Future<void> _loadThemeState() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      _themeMode = themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _authService.login(email: email, password: password);
    
    if (result['success'] == true) {
      final user = result['user'];
      _isAuthenticated = true;
      _userName = (user['full_name'] ?? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}').trim();
      if (_userName.isEmpty) _userName = user['username'] ?? 'User';
      _userLocation = (user['location'] ?? '').trim();
      if (_userLocation.isEmpty) _userLocation = 'Location';
      _userEmail = (user['email'] ?? '').trim();
      _userPhone = (user['phone'] ?? '').trim();
      _isDoctor = user['is_doctor'] ?? false;
      _isPharmacist = user['is_pharmacist'] ?? false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userName', _userName);
      await prefs.setString('userLocation', _userLocation);
      await prefs.setString('userEmail', _userEmail);
      await prefs.setString('userPhone', _userPhone);
      await prefs.setBool('isDoctor', _isDoctor);
      await prefs.setBool('isPharmacist', _isPharmacist);
      
      // Reset tab index to 0 (home/dashboard) on login
      _currentTabIndex = 0;
      
      notifyListeners();
      return {'success': true};
    }
    return {'success': false, 'error': result['error']};
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    required String location,
    required String phone,
  }) async {
    final result = await _authService.register(
      username: email.split('@')[0],
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      location: location,
    );
    
    if (result['success'] == true) {
      final user = result['user'];
      _isAuthenticated = true;
      _userName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
      if (_userName.isEmpty) _userName = user['username'] ?? 'User';
      _userLocation = (user['location'] ?? '').trim();
      if (_userLocation.isEmpty) _userLocation = 'Location';
      _userEmail = (user['email'] ?? '').trim();
      _userPhone = (user['phone'] ?? '').trim();
      _isDoctor = user['is_doctor'] ?? false;
      _isPharmacist = user['is_pharmacist'] ?? false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userName', _userName);
      await prefs.setString('userLocation', _userLocation);
      await prefs.setString('userEmail', _userEmail);
      await prefs.setString('userPhone', _userPhone);
      await prefs.setBool('isDoctor', _isDoctor);
      await prefs.setBool('isPharmacist', _isPharmacist);
      
      // Reset tab index to 0 (home/dashboard) on registration
      _currentTabIndex = 0;
      
      notifyListeners();
      return {'success': true};
    }
    return {'success': false, 'error': result['error']};
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _isDoctor = false;
    _isPharmacist = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.setBool('isDoctor', false);
    await prefs.setBool('isPharmacist', false);
    await prefs.remove('userName');
    await prefs.remove('userLocation');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('themeMode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    });
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateUserInfo(String name, String location) async {
    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    final result = await _authService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      location: location,
    );
    
    if (result['success'] == true) {
      final user = result['user'];
      _userName = user['full_name'] ?? name;
      _userLocation = user['location'] ?? location;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _userName);
      await prefs.setString('userLocation', _userLocation);
      
      notifyListeners();
      return {'success': true};
    }
    return {'success': false, 'error': result['error']};
  }

  // Current tab
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
