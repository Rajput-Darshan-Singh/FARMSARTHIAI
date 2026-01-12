class DiseaseDetection {
  final String id;
  final String diseaseName;
  final double confidence;
  final String imageUrl;
  final String inputType;
  final Map<String, dynamic> answers;
  final List<Treatment> treatments;
  final List<String> preventiveMeasures;
  final DateTime detectedAt;

  DiseaseDetection({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.imageUrl,
    required this.inputType,
    required this.answers,
    required this.treatments,
    required this.preventiveMeasures,
    required this.detectedAt,
  });

  factory DiseaseDetection.fromJson(Map<String, dynamic> json) {
    return DiseaseDetection(
      id: json['_id'] ?? json['id'],
      diseaseName: json['diseaseName'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      inputType: json['inputType'] ?? 'image',
      answers: Map<String, dynamic>.from(json['answers'] ?? {}),
      treatments: (json['treatments'] as List? ?? []).map((t) => Treatment.fromJson(t)).toList(),
      preventiveMeasures: List<String>.from(json['preventiveMeasures'] ?? []),
      detectedAt: DateTime.parse(json['detectedAt']),
    );
  }
}

class Treatment {
  final String name;
  final String description;
  final String dosage;
  final String application;
  final String safety;

  Treatment({
    required this.name,
    required this.description,
    required this.dosage,
    required this.application,
    required this.safety,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      name: json['name'],
      description: json['description'],
      dosage: json['dosage'],
      application: json['application'],
      safety: json['safety'],
    );
  }
}