import 'package:flutter/material.dart';
import '../app_localizations.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How to take good plant photos?',
      answer:
          '• Take photos in good natural lighting (avoid harsh shadows)\n• Focus on affected areas clearly\n• Include both close-up shots of symptoms and full plant views\n• Take multiple angles if possible\n• Ensure the image is clear and not blurry',
    ),
    FAQItem(
      question: 'What information should I provide?',
      answer:
          '• Crop type and variety\n• Symptoms observed (color changes, spots, wilting, etc.)\n• Weather conditions (recent rain, temperature)\n• Previous treatments used\n• Stage of crop growth\n• Affected area percentage',
    ),
    FAQItem(
      question: 'How accurate is the disease detection?',
      answer:
          'Our AI model provides detection with confidence scores. Higher confidence (above 70%) indicates more reliable results. For critical decisions, we recommend consulting with agricultural experts.',
    ),
    FAQItem(
      question: 'What should I do if no disease is detected?',
      answer:
          'If no disease is detected but symptoms persist, try:\n• Taking clearer photos from different angles\n• Providing more detailed symptom descriptions\n• Consulting with local agricultural extension services\n• Contacting our expert support team',
    ),
    FAQItem(
      question: 'Are the recommended treatments safe?',
      answer:
          'All treatments are based on standard agricultural practices. However, always:\n• Follow label instructions carefully\n• Use appropriate protective equipment\n• Consider organic alternatives when possible\n• Consult local agricultural authorities for region-specific advice',
    ),
    FAQItem(
      question: 'Can I use this app offline?',
      answer:
          'The app requires internet connection for disease detection. However, FAQs and language packs are cached for offline access.',
    ),
    FAQItem(
      question: 'How do I contact an expert?',
      answer:
          'You can contact our agricultural experts through:\n• The "Expert Help" button in results screen\n• Email support (coming soon)\n• Phone helpline (coming soon)\n• In-app chat (coming soon)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('help')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.tertiary.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Help?',
                            style: theme.textTheme.headlineMedium,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Find answers to common questions',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              appLocalizations.translate('faq'),
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            // FAQ List
            ..._faqs.map((faq) => Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      faq.question,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          faq.answer,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: 24),
            // Contact Support Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.contact_support,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          appLocalizations.translate('contactSupport'),
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Still need help? Contact our support team for personalized assistance.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Contact Support'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: support@cropdisease.com'),
                                  SizedBox(height: 8),
                                  Text('Phone: +91 1800-XXX-XXXX'),
                                  SizedBox(height: 8),
                                  Text('Hours: Mon-Sat, 9 AM - 6 PM'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.email),
                        label: Text('Get in Touch'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
