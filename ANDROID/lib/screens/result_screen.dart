import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crop_disease_app/screens/StoresScreen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final String inputText;
  final Map<String, dynamic> answers;
  final Map<String, dynamic> apiResult;

  const ResultScreen({
    Key? key,
    required this.imagePath,
    required this.inputText,
    required this.answers,
    required this.apiResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<String, dynamic> data =
        (apiResult['data'] as Map?)?.cast<String, dynamic>() ?? {};

    final Map<String, dynamic> ctx =
        (data['context'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic> diseaseDetails =
        (data['disease_details'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic> weather =
        (ctx['weather'] as Map?)?.cast<String, dynamic>() ?? {};

    // Language-aware details
    final Map<String, dynamic> allLanguages =
        (diseaseDetails['all_languages'] as Map?)?.cast<String, dynamic>() ??
            {};
    final String langCode = (ctx['language'] ?? 'en').toString();
    final String langKey = _mapLangCodeToKey(langCode);
    final Map<String, dynamic> localized =
        (allLanguages[langKey] as Map?)?.cast<String, dynamic>() ?? {};

    final String diseaseName =
        (localized['name'] ?? diseaseDetails['name'] ?? '').toString();
    final String localName =
        (localized['local_name'] ?? diseaseDetails['local_name'] ?? '')
            .toString();
    final String cause =
        (localized['cause'] ?? diseaseDetails['cause'] ?? '').toString();
    final String imageUrl = (diseaseDetails['image_url'] ?? '').toString();

    final List<dynamic> pesticides = (localized['pesticides'] as List?) ??
        (diseaseDetails['pesticides'] as List?) ??
        (localized['pesticicides'] as List?) ?? // Alternative spelling
        const [];
    final List<dynamic> pesticidesList = (localized['pesticides'] as List?) ??
        (diseaseDetails['pesticides'] as List?) ??
        [];

    final List<Map<String, dynamic>> allPesticides = pesticidesList
        .map((item) => {
              "name": (item["name"] ?? "").toString(),
              "image": (item["image_link"] ?? "").toString(),
              "category":
                  _getPesticideCategory((item["name"] ?? "").toString()),
            })
        .toList();

    final List<dynamic> solutions = (localized['solutions'] as List?) ??
        (diseaseDetails['solutions'] as List?) ??
        const [];

    final String season = (ctx['season'] ?? '').toString();
    final String humidity = weather['humidity']?.toString() ?? '-';
    final String temperature = weather['temperature']?.toString() ?? '-';

    // Get schemes - Use ONLY from disease_details to avoid duplicates
    final List<dynamic> schemes =
        (diseaseDetails['eligible_schemes'] as List?) ?? const [];

    // Clean up schemes list to remove duplicates
    final List<Map<String, dynamic>> uniqueSchemes = [];
    final Set<String> schemeNames = {};

    for (var scheme in schemes) {
      final Map<String, dynamic> schemeMap = scheme.cast<String, dynamic>();
      final String name = (schemeMap['name'] ?? '').toString();
      final String url = (schemeMap['official_link'] ?? '').toString();

      if (name.isNotEmpty && !schemeNames.contains(name)) {
        schemeNames.add(name);
        uniqueSchemes.add({
          'name': name,
          'url': url,
        });
      }
    }

    // Final confidence
    final Map<String, dynamic> prediction =
        (data['prediction'] as Map?)?.cast<String, dynamic>() ?? {};
    final double confidence =
        (prediction['confidence'] as num?)?.toDouble() ?? 0.0;
    final String confidencePercent =
        '${(confidence * 100).toStringAsFixed(1)}%';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detection Result', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D6A4F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Disease Name and Confidence
                          Text(
                            diseaseName.isNotEmpty
                                ? diseaseName
                                : 'Healthy Plant',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          if (localName.isNotEmpty)
                            Text(
                              '($localName)',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Disease Image
                    Container(
                      height: 200,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildDiseaseImage(imageUrl, theme),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                // Causes & Prevention
                if (cause.isNotEmpty) _buildCausePreventionCard(cause, theme),

                // Solutions Section
                if (solutions.isNotEmpty) _buildSolutionsCard(solutions, theme),

                // Pesticides Section with Images
                if (allPesticides.isNotEmpty)
                  _buildPesticidesSection(allPesticides.toList(), theme),
                // Government Schemes (Bottom Section)
                if (uniqueSchemes.isNotEmpty)
                  _buildSchemesSection(uniqueSchemes, theme),

                // Weather & Season Info
                _buildWeatherSeasonCard(season, humidity, temperature, theme),

                const SizedBox(height: 80), // Bottom padding for FAB
              ]),
            ),
          ],
        ),
      ),
    );
  }

  static String _mapLangCodeToKey(String code) {
    switch (code.toLowerCase()) {
      case 'hi':
        return 'hindi';
      case 'kn':
      case 'ka':
        return 'kannada';
      case 'mr':
        return 'marathi';
      case 'en':
      default:
        return 'english';
    }
  }

  Widget _buildDiseaseImage(String imageUrl, ThemeData theme) {
    if (imageUrl.isNotEmpty) {
      // Optimize: Add compression query params if backend supports
      final optimizedUrl = _optimizeImageUrl(imageUrl);

      return CachedNetworkImage(
        width: double.infinity,
        height: double.infinity,
        imageUrl: optimizedUrl,
        fit: BoxFit.cover,

        // Aggressive caching for speed
        cacheKey: imageUrl,
        memCacheHeight: 400,
        memCacheWidth: 400,
        maxHeightDiskCache: 400,
        maxWidthDiskCache: 400,

        placeholder: (context, url) => Container(
          color: const Color(0xFFE9F5DB),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF2D6A4F)),
              ),
              const SizedBox(height: 8),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF2D6A4F).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        errorWidget: (context, url, error) => _buildFallbackImage(theme),

        // Fast fade
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
      );
    }
    return _buildFallbackImage(theme);
  }

// Optimize image URL for faster loading
  String _optimizeImageUrl(String url) {
    // Add size/compression params if URL structure supports it
    if (url.contains('?')) {
      return '$url&w=400&h=400&q=85';
    } else {
      return '$url?w=400&h=400&q=85';
    }
  }
  // Widget _buildDiseaseImage(String imageUrl, ThemeData theme) {
  //   if (imageUrl.isNotEmpty) {
  //     return CachedNetworkImage(
  //         width: double.infinity,
  // height: double.infinity,
  //       imageUrl: imageUrl,
  //       fit: BoxFit.cover,
  //       placeholder: (context, url) => Container(
  //         color: const Color(0xFFE9F5DB),
  //         alignment: Alignment.center,
  //         child: const CircularProgressIndicator(color: Color(0xFF2D6A4F)),
  //       ),
  //       errorWidget: (context, url, error) => _buildFallbackImage(theme),
  //     );
  //   }
  //   return _buildFallbackImage(theme);
  // }

  Widget _buildFallbackImage(ThemeData theme) {
    if (imagePath.isNotEmpty) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
      );
    }

    return Container(
      color: const Color(0xFFE9F5DB),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture,
            size: 60,
            color: const Color(0xFF2D6A4F).withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Text(
            'Plant Image',
            style: TextStyle(
              color: const Color(0xFF2D6A4F).withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildSolutionsCard(List<dynamic> solutions, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: const Color(0xFF2D6A4F)),
                  const SizedBox(width: 8),
                  Text(
                    'Recommended Solutions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D6A4F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Solutions List
              Column(
                children: solutions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final solution = entry.value.toString();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Number Badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Solution Text
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7F4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              solution,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Color(0xFF2D6A4F),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPesticidesSection(
      List<Map<String, dynamic>> pesticides, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: const [
                  Icon(Icons.medical_services,
                      color: Color(0xFF2D6A4F), size: 26),
                  SizedBox(width: 10),
                  Text(
                    "Recommended Pesticides",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D6A4F),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- SLIDER ----------------
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.82),
                  itemCount: pesticides.length,
                  itemBuilder: (context, index) {
                    final p = pesticides[index];

                    // Normalize/guard fields to avoid nulls causing type errors
                    final String pesticideImage =
                        (p["image"] ?? p["image_link"] ?? '').toString();
                    final String pesticideName = (p["name"] ?? '').toString();
                    final String pesticideCategory =
                        (p["category"] ?? '').toString();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFF0F7F4),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          if (pesticideImage.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: pesticideImage,
                                    fit: BoxFit.cover,
                                    errorWidget: (c, u, e) => Icon(
                                      Icons.local_pharmacy,
                                      size: 60,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            // IMAGE
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                color: const Color(0xFFE3F3DB),
                                child: pesticideImage.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: pesticideImage,
                                        fit: BoxFit.cover,
                                        errorWidget: (c, u, e) => Icon(
                                          Icons.local_pharmacy,
                                          size: 60,
                                          color: Colors.green.shade700,
                                        ),
                                      )
                                    : Icon(
                                        Icons.local_pharmacy,
                                        size: 60,
                                        color: Colors.green.shade700,
                                      ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // NAME
                            if (pesticideName.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(
                                      pesticideCategory.isNotEmpty
                                          ? pesticideCategory
                                          : ''),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  pesticideName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- FIND STORES BUTTON ----------------
              Builder(
                builder: (context) {
                  final double? lat = 15.814722213646322;
                  final double? lon = 74.48806008465743;

                  return GestureDetector(
                    onTap: () {
                      if (lat != null && lon != null) {
                        _findStores(context, lat, lon);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Location not available")),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2D6A4F),
                            Color(0xFF40916C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.store_mall_directory,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Find Nearby Agro Stores",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCausePreventionCard(String cause, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: const Color(0xFF2D6A4F)),
                  const SizedBox(width: 8),
                  Text(
                    'Cause',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D6A4F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cause,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherSeasonCard(
      String season, String humidity, String temperature, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny, color: const Color(0xFF2D6A4F)),
                  const SizedBox(width: 8),
                  Text(
                    'Field Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D6A4F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Conditions Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildConditionItem(
                    icon: Icons.eco,
                    label: 'Season',
                    value: season,
                    color: Colors.green,
                  ),
                  _buildConditionItem(
                    icon: Icons.thermostat,
                    label: 'Temperature',
                    value: '$temperature°C',
                    color: Colors.orange,
                  ),
                  _buildConditionItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '$humidity%',
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D6A4F),
          ),
        ),
      ],
    );
  }

  Widget _buildSchemesSection(
      List<Map<String, dynamic>> schemes, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.account_balance, color: Color(0xFF2D6A4F)),
                  SizedBox(width: 10),
                  Text(
                    'Government Schemes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D6A4F),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Schemes List
              ...schemes.map((scheme) {
                final String name = scheme['name'] ?? '';
                final String url = scheme['url'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Color(0xFF2D6A4F).withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (url.isNotEmpty) _launchUrl(url);
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF2D6A4F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              Icon(Icons.agriculture, color: Color(0xFF2D6A4F)),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Color(0xFF2D6A4F),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                url.isNotEmpty
                                    ? 'Tap to visit official website'
                                    : 'Website link not available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: url.isNotEmpty
                                      ? Colors.grey[600]
                                      : Colors.red[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Color(0xFF2D6A4F)),
                      ],
                    ),
                  ),
                );
              }).toList(),

              SizedBox(height: 8),

              // CALL TO APPLY Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D6A4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    const phone = 'tel:7019431427';
                    await _launchUrl(phone);
                  },
                  icon: Icon(Icons.call, color: Colors.white),
                  label: Text(
                    "CALL TO APPLY",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getPesticideCategory(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('streptocycline') ||
        lowerName.contains('oxychloride') ||
        lowerName.contains('bordeaux')) {
      return 'Bactericide';
    } else if (lowerName.contains('mancozeb') ||
        lowerName.contains('carbendazim') ||
        lowerName.contains('propiconazole') ||
        lowerName.contains('tricyclazole') ||
        lowerName.contains('azoxystrobin') ||
        lowerName.contains('isoprothiolane')) {
      return 'Fungicide';
    } else if (lowerName.contains('imidacloprid') ||
        lowerName.contains('thiamethoxam')) {
      return 'Insecticide';
    }

    return null;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fungicide':
        return Colors.orange[700]!;
      case 'insecticide':
        return Colors.purple[700]!;
      case 'bactericide':
        return Colors.blue[700]!;
      default:
        return const Color(0xFF2D6A4F);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _findStores(BuildContext context, double lat, double lon) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final url = "http://10.215.157.116:5000/findStores?lat=$lat&lon=$lon";

    try {
      final res = await http.get(Uri.parse(url));
      Navigator.pop(context); // close loading dialog

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoresScreen(
              stores: data["shops"] ?? [],
              coordinatesUsed: data["coordinates_used"] ?? {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Error ${res.statusCode}")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
