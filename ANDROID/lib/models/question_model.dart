class Question {
  final String id;
  final String text;
  final List<String> options;
  final String type;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      type: json['type'],
    );
  }
}

// Predefined questions for disease context
final List<Question> diagnosticQuestions = [
  Question(
    id: 'crop_type',
    text: 'What type of crop is affected?',
    options: ['Maize', 'Rice', 'Wheat', 'Vegetables', 'Fruits', 'Other'],
    type: 'single',
  ),
  Question(
    id: 'symptoms',
    text: 'What symptoms do you observe?',
    options: [
      'Yellow leaves',
      'Brown spots',
      'White powder',
      'Wilting',
      'Stunted growth',
      'Other'
    ],
    type: 'multiple',
  ),
  Question(
    id: 'affected_area',
    text: 'How much of the crop is affected?',
    options: ['Small patches', 'About 25%', 'About 50%', 'About 75%', 'Entire field'],
    type: 'single',
  ),
  Question(
    id: 'farming_practice',
    text: 'What farming practices do you use?',
    options: ['Organic', 'Conventional', 'Mixed', 'Not sure'],
    type: 'single',
  ),
  Question(
    id: 'previous_treatment',
    text: 'Have you used any treatments before?',
    options: ['None', 'Chemical pesticides', 'Organic remedies', 'Biological controls'],
    type: 'single',
  ),
];