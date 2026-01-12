import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import '../widgets/image_input.dart';
// language switch removed from header
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  String _selectedImagePath = '';
  bool _isSubmitting = false;
  String _languageCode = 'en';
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _loadUserPrefs();
  }

  Future<void> _loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLocation = prefs.getString('user_location');

    if (storedLocation != null) {
      // Stored in format: "Lat: xx.xxxxxx, Lng: yy.yyyyyy"
      final parts = storedLocation.split(',');
      if (parts.length == 2) {
        final latPart = parts[0].replaceAll('Lat:', '').trim();
        final lngPart = parts[1].replaceAll('Lng:', '').trim();
        _lat = double.tryParse(latPart);
        _lng = double.tryParse(lngPart);
      }
    }

    final localStorage = LocalStorage();
    final lang = await localStorage.getLanguage();

    if (mounted) {
      setState(() {
        _languageCode = lang;
      });
    }
  }

  void _onImageSelected(String imagePath) {
    setState(() => _selectedImagePath = imagePath);
  }

  Future<void> _submitForDetection() async {
    if (_selectedImagePath.isEmpty) {
      _showError("Please select an image");
      return;
    }

    if (_lat == null || _lng == null) {
      _showError("Location is missing. Please set it on the profile screen.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService().submitPlantImage(
        File(_selectedImagePath),
        lat: _lat!.toString(),
        lon: _lng!.toString(),
        lang: _languageCode,
      );

      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => ResultScreen(
            imagePath: _selectedImagePath,
            inputText: '',
            answers: {},
            apiResult: result,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      
      appBar: AppBar(
        title: Text(appLocalizations.translate('detectDisease')),
        backgroundColor: Color(0xFF4A7C59),
      ),
      body: Container(
          width: double.infinity,
  height: double.infinity,     
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA8D5BA).withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: ImageInput(onImageSelected: _onImageSelected),
      ),
      bottomNavigationBar: _selectedImagePath.isNotEmpty
          ? _isSubmitting
              ? _loadingBar(theme)
              : _submitButton(theme)
          : SizedBox.shrink(),
    );
  }

  Widget _loadingBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF4A7C59),
            strokeWidth: 3,
          ),
          SizedBox(height: 12),
          Text(
            "Processing image...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4A7C59).withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _submitForDetection,
          icon: Icon(Icons.search, size: 24),
          label: Text(
            "Detect Disease",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A7C59),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
