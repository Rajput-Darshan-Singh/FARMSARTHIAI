import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      // Handle the response structure from Express server
      if (response['message'] != null && response['token'] != null) {
        // Store token and user data from the response
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response['token']);
        await prefs.setString('userId', response['id'] ?? '');
        await prefs.setString('userName', response['name'] ?? '');
        await prefs.setString('userEmail', response['email'] ?? '');

        // Return success response in expected format
        return {
          'success': true,
          'message': response['message'],
          'token': response['token'],
          'user': {
            'id': response['id'],
            'name': response['name'],
            'email': response['email'],
            'role': response['role'],
          }
        };
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } catch (error) {
      return {
        'success': false,
        'message': error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String phone) async {
    try {
      final response = await _apiService.register(name, email, password, phone);

      // Handle the response structure from Express server
      if (response['message'] != null) {
        return {
          'success': true,
          'message': response['message'],
          'data': response['data'] ?? response,
        };
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } catch (error) {
      return {
        'success': false,
        'message': error.toString(),
      };
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<Map<String, String>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('userId') ?? '',
      'name': prefs.getString('userName') ?? '',
      'email': prefs.getString('userEmail') ?? '',
    };
  }
}
