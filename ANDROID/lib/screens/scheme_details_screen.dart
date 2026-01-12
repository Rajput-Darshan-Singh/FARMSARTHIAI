import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scheme_model.dart';
import '../app_localizations.dart';

class SchemeDetailsScreen extends StatelessWidget {
  final Scheme scheme;

  const SchemeDetailsScreen({Key? key, required this.scheme}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = AppLocalizations.of(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('schemeDetails')),
        backgroundColor: Color(0xFF4A7C59),
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scheme Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.agriculture,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (scheme.name[lang] ?? scheme.name['en']) ??
                                    scheme.name.values.first,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A7C59),
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  scheme.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Description
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('description'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A7C59),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      (scheme.description[lang] ?? scheme.description['en']) ??
                          scheme.description.values.first,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Eligibility
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).translate('eligibility'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      (scheme.eligibility[lang] ?? scheme.eligibility['en']) ??
                          scheme.eligibility.values.first,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Benefits
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).translate('benefits'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...((scheme.benefits[lang] ?? scheme.benefits['en'] ?? [])
                        .map((benefit) => Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      benefit,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList()),
                  ],
                ),
              ),
              // SizedBox(height: 30),
              // // Action Buttons
              // Column(
              //   children: [
              //     // Apply Now Button
              //     SizedBox(
              //       width: double.infinity,
              //       height: 56,
              //       child: ElevatedButton.icon(
              //         onPressed: () => _launchURL(scheme.officialLink),
              //         icon: Icon(Icons.open_in_new, size: 24),
              //         label: Text(
              //           'Apply Now',
              //           style: TextStyle(
              //             fontSize: 18,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Color(0xFF4A7C59),
              //           foregroundColor: Colors.white,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //           elevation: 4,
              //         ),
              //       ),
              //     ),
              //     SizedBox(height: 16),
              //     // Tutorial Button
              //     SizedBox(
              //       width: double.infinity,
              //       height: 56,
              //       child: OutlinedButton.icon(
              //         onPressed: () => _launchURL(scheme.tutorialLink),
              //         icon: Icon(Icons.play_circle_outline, size: 24),
              //         label: Text(
              //           'Watch Tutorial on YouTube',
              //           style: TextStyle(
              //             fontSize: 18,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         style: OutlinedButton.styleFrom(
              //           foregroundColor: Color(0xFF4A7C59),
              //           side: BorderSide(color: Color(0xFF4A7C59), width: 2),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
