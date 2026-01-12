import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = true; // Add loading state
  String? _token;
  String? _userId;
  String? _userName;
  String? _userEmail; // Add email field

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading; // Add getter
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  AuthProvider() {
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _userId = prefs.getString('userId');
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
      _isAuthenticated = _token != null;
    } catch (e) {
      print('Error loading auth data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);

      if (response['success'] == true && response['token'] != null) {
        _token = response['token'];
        _userId = response['user']['id'];
        _userName = response['user']['name'];
        _userEmail = response['user']['email'];
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userId', _userId!);
        await prefs.setString('userName', _userName!);
        await prefs.setString('userEmail', _userEmail!);

        notifyListeners();
        return true;
      }
      print('Login failed: ${response['message']}');
      return false;
    } catch (error) {
      print('Login error: $error');
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String phone) async {
    try {
      final response =
          await _authService.register(name, email, password, phone);

      if (response['success'] == true) {
        // After successful registration, login the user
        return await login(email, password);
      }
      print('Registration failed: ${response['message']}');
      return false;
    } catch (error) {
      print('Registration error: $error');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _authService.logout();

      _isAuthenticated = false;
      _token = null;
      _userId = null;
      _userName = null;
      _userEmail = null;

      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
