import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import 'scheme_details_screen.dart';
import '../app_localizations.dart';

class SchemesListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('governmentSchemes'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF4A7C59),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFA8D5BA).withOpacity(0.3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: demoSchemes.length,
          itemBuilder: (context, index) {
            final scheme = demoSchemes[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchemeDetailsScreen(scheme: scheme),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(bottom: 18),
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFF5FFF9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER ROW
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF4A7C59).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.eco_rounded,
                            size: 26,
                            color: Color(0xFF4A7C59),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // show name according to selected language with fallback to English
                                (scheme.name[lang] ?? scheme.name['en']) ?? '',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF355E3B),
                                ),
                              ),

                              SizedBox(height: 6),

                              // Container(
                              //   padding: EdgeInsets.symmetric(
                              //     horizontal: 10,
                              //     vertical: 4,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: Color(0xFF4A7C59).withOpacity(0.12),
                              //     borderRadius: BorderRadius.circular(8),
                              //   ),
                              //   child: Text(
                              //     scheme.category,
                              //     style: TextStyle(
                              //       fontSize: 12,
                              //       color: Color(0xFF4A7C59),
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 20, color: Colors.grey)
                      ],
                    ),

                    SizedBox(height: 16),
                    Divider(height: 1, thickness: 1, color: Colors.black12),
                    SizedBox(height: 16),

                    // DESCRIPTION
                    Text(
                      // show description according to selected language with fallback
                      (scheme.description[lang] ?? scheme.description['en']) ??
                          '',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
