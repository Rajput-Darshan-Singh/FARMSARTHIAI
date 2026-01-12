import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disease_model.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = Constants.apiBaseUrl;
  String? _token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'token': _token!,
    };
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        throw Exception('Authentication failed');
      } else {
        final errorMessage = data['message'] ??
            'Request failed with status ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup')) {
        throw Exception('Server unreachable. Check your network.');
      }
      rethrow;
    }
  }

  // -------------------------------------------------------------
  // 🔥 Upload image + location data to Python /predict route
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> submitPlantImage(
    File imageFile, {
    required String lat,
    required String lon,
    required String lang,
  }) async {
    await _loadToken();

    // This endpoint is hosted by the Python service (separate from main API)
    final uri = Uri.parse("http://10.215.157.116:5000/predict");

    var request = http.MultipartRequest("POST", uri);

    // Optional auth headers (Python backend can read either one)
    if (_token != null) {
      request.headers['token'] = _token!;
      request.headers['Authorization'] = 'Bearer $_token';
    }

    // Attach the plant image
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // Flask expects request.files['image']
        imageFile.path,
      ),
    );

    // Attach additional form fields
    request.fields.addAll({
      'lat': lat,
      'lon': lon,
      'lang': lang,
    });

    // Send request
    final streamedResponse = await request.send();
    final resBody = await streamedResponse.stream.bytesToString();

    try {
      final jsonRes = json.decode(resBody);
      return {
        'status': streamedResponse.statusCode,
        'data': jsonRes,
      };
    } catch (e) {
      return {
        'status': streamedResponse.statusCode,
        'error': 'Invalid JSON from server',
        'raw': resBody,
      };
    }
  }

  // -------------------------------------------------------------
  // Existing authentication endpoints
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login'),
      headers: _headers,
      body: json.encode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String phone) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register'),
      headers: _headers,
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    return _handleResponse(response);
  }

  // -------------------------------------------------------------
  // Disease detection (your existing ML + questions API)
  // -------------------------------------------------------------
  Future<DiseaseDetection> detectDisease({
    required String? imagePath,
    required Map<String, dynamic> answers,
    required String inputType,
  }) async {
    await _loadToken();

    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/disease/detect'));

    request.headers.addAll({'token': _token!});

    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    request.fields.addAll({
      'answers': json.encode(answers),
      'inputType': inputType,
    });

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseData);

    if (response.statusCode == 200) {
      return DiseaseDetection.fromJson(jsonResponse['data']);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Detection failed');
    }
  }

  // -------------------------------------------------------------
  // Profile / help endpoints
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> requestExpertHelp(
      String detectionId, String message) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/help/request'),
      headers: _headers,
      body: json.encode({
        'detectionId': detectionId,
        'message': message,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    await _loadToken();
    final response = await http.put(
      Uri.parse('$baseUrl/user/profile'),
      headers: _headers,
      body: json.encode(profileData),
    );
    return _handleResponse(response);
  }
}
