import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class DiseaseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _detectionResult;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get detectionResult => _detectionResult;

  Future<void> detectDisease({
    required String? imagePath,
    required Map<String, dynamic> answers,
    required String inputType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.detectDisease(
        imagePath: imagePath,
        answers: answers,
        inputType: inputType,
      );

      _detectionResult = {
        'diseaseName': result.diseaseName,
        'confidence': result.confidence,
        'treatments': result.treatments,
        'preventiveMeasures': result.preventiveMeasures,
      };
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _detectionResult = null;
    _error = null;
    notifyListeners();
  }
}
