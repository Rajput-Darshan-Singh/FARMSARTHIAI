// -------------------------------------------------------------
// SCHEME MODEL (MULTI-LANGUAGE) + FULL DATA
// -------------------------------------------------------------

class Scheme {
  final String id;
  final Map<String, String> name;          // en, hi, kn, mr
  final Map<String, String> description;   // en, hi, kn, mr
  final String officialLink;
  final String tutorialLink;
  final String category;
  final Map<String, List<String>> benefits;  // en, hi, kn, mr
  final Map<String, String> eligibility;     // en, hi, kn, mr

  Scheme({
    required this.id,
    required this.name,
    required this.description,
    required this.officialLink,
    required this.tutorialLink,
    required this.category,
    required this.benefits,
    required this.eligibility,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      id: json['id'],
      name: Map<String, String>.from(json['name']),
      description: Map<String, String>.from(json['description']),
      officialLink: json['officialLink'],
      tutorialLink: json['tutorialLink'],
      category: json['category'],
      benefits: Map<String, List<String>>.from(
        json['benefits'].map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      eligibility: Map<String, String>.from(json['eligibility']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'officialLink': officialLink,
      'tutorialLink': tutorialLink,
      'category': category,
      'benefits': benefits,
      'eligibility': eligibility,
    };
  }
}

// -------------------------------------------------------------
// FULL MULTI-LANGUAGE SCHEMES DATA
// -------------------------------------------------------------

final List<Scheme> demoSchemes = [

  // ---------------------------------------------------------
  // 1. PM-KISAN
  // ---------------------------------------------------------
  Scheme(
    id: '1',
    name: {
      'en': 'PM Kisan Samman Nidhi (PM-KISAN)',
      'hi': 'पीएम किसान सम्मान निधि (PM-KISAN)',
      'kn': 'ಪಿಎಂ ಕಿಸಾನ್ ಸಮ್ಮಾನ್ ನಿಧಿ (PM-KISAN)',
      'mr': 'पीएम किसान सन्मान निधी (PM-KISAN)',
    },
    description: {
      'en': 'Direct income support of ₹6,000 per year for farmers.',
      'hi': 'किसानों को प्रति वर्ष ₹6,000 की आर्थिक सहायता दी जाती है।',
      'kn': 'ಕೃಷಿಕರಿಗೆ ವರ್ಷಕ್ಕೆ ₹6,000 ನೇರ ಆರ್ಥಿಕ ಸಹಾಯ.',
      'mr': 'शेतकऱ्यांना दरवर्षी ₹6,000 थेट आर्थिक मदत दिली जाते.',
    },
    officialLink: 'https://pmkisan.gov.in/homenew.aspx',
    tutorialLink:
        'https://www.youtube.com/results?search_query=PM+KISAN+scheme+how+to+apply',
    category: 'Income Support',
    benefits: {
      'en': [
        '₹6,000 per year',
        'Direct bank transfer',
        'No middlemen'
      ],
      'hi': [
        '₹6,000 प्रति वर्ष',
        'बैंक खाते में सीधा ट्रांसफर',
        'कोई बिचौलिया नहीं'
      ],
      'kn': [
        'ವರ್ಷಕ್ಕೆ ₹6,000',
        'ಬ್ಯಾಂಕ್ ಖಾತೆಗೆ ನೇರ ಜಮಾ',
        'ಮಧ್ಯವರ್ತಿ ಇಲ್ಲ'
      ],
      'mr': [
        'वर्षाला ₹6,000',
        'बँक खात्यात थेट जमा',
        'कोणतेही दलाल नाहीत'
      ],
    },
    eligibility: {
      'en': 'All landholding farmers are eligible.',
      'hi': 'सभी भूमिधर किसान पात्र हैं।',
      'kn': 'ಎಲ್ಲಾ ಜಮೀನುದಾರ ರೈತರು ಅರ್ಹರು.',
      'mr': 'सर्व जमीनधारक शेतकरी पात्र आहेत.',
    },
  ),

  // ---------------------------------------------------------
  // 2. PMFBY
  // ---------------------------------------------------------
  Scheme(
    id: '2',
    name: {
      'en': 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
      'hi': 'प्रधानमंत्री फसल बीमा योजना (PMFBY)',
      'kn': 'ಪ್ರಧಾನ ಮಂತ್ರಿ ಫಸಲ್ ಬೀಮಾ ಯೋಜನೆ (PMFBY)',
      'mr': 'प्रधानमंत्री पिक विमा योजना (PMFBY)',
    },
    description: {
      'en': 'Crop insurance for financial support in case of crop loss.',
      'hi': 'फसल नुकसान होने पर आर्थिक सहायता देने हेतु फसल बीमा योजना।',
      'kn': 'ಬೆಳೆ ನಷ್ಟದ ಸಂದರ್ಭದಲ್ಲಿಂಥ ಬೆಳೆ ವಿಮೆ.',
      'mr': 'पिक नुकसानीसाठी आर्थिक मदत देणारी पिक विमा योजना.',
    },
    officialLink: 'https://pmfby.gov.in/',
    tutorialLink:
        'https://www.youtube.com/results?search_query=PMFBY+crop+insurance+how+to+apply',
    category: 'Insurance',
    benefits: {
      'en': [
        'Low premium',
        'Full coverage',
        'Fast claim settlement'
      ],
      'hi': [
        'कम प्रीमियम',
        'पूर्ण कवरेज',
        'तेज़ क्लेम प्रक्रिया'
      ],
      'kn': [
        'ಕಡಿಮೆ ಪ್ರೀಮಿಯಂ',
        'ಸಂಪೂರ್ಣ ಕವರ್',
        'ವೇಗವಾದ ಕ್ಲೇಮ್'
      ],
      'mr': [
        'कमी प्रीमियम',
        'पूर्ण संरक्षण',
        'त्वरित क्लेम'
      ],
    },
    eligibility: {
      'en': 'All farmers growing notified crops.',
      'hi': 'सूचित फसल उगाने वाले सभी किसान पात्र हैं।',
      'kn': 'ಸೂಚಿಸಲಾದ ಬೆಳೆ ಬೆಳೆಯುವ ಎಲ್ಲಾ ರೈತರು ಅರ್ಹರು.',
      'mr': 'सूचित पिक घेणारे सर्व शेतकरी पात्र आहेत.',
    },
  ),

  // ---------------------------------------------------------
  // 3. KCC
  // ---------------------------------------------------------
  Scheme(
    id: '3',
    name: {
      'en': 'Kisan Credit Card (KCC)',
      'hi': 'किसान क्रेडिट कार्ड (KCC)',
      'kn': 'ಕಿಸಾನ್ ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್ (KCC)',
      'mr': 'किसान क्रेडिट कार्ड (KCC)',
    },
    description: {
      'en': 'Loan facility for farmers to meet short-term credit needs.',
      'hi': 'किसानों की अल्पकालिक ऋण आवश्यकताओं को पूरा करने के लिए ऋण सुविधा।',
      'kn': 'ಕೃಷಿಕರ ಕಿರು ಅವಧಿ ಸಾಲ ಅಗತ್ಯಗಳಿಗೆ ಸಾಲ ಸೌಲಭ್ಯ.',
      'mr': 'शेतकऱ्यांच्या अल्पकालीन कर्ज गरजा पूर्ण करण्यासाठी कर्ज सुविधा.',
    },
    officialLink: 'https://www.india.gov.in/kisan-credit-card-kcc',
    tutorialLink:
        'https://www.youtube.com/results?search_query=Kisan+Credit+Card+how+to+apply',
    category: 'Credit',
    benefits: {
      'en': [
        'Easy loan approval',
        'Interest subsidy',
        'Flexible repayment'
      ],
      'hi': [
        'आसान ऋण स्वीकृति',
        'ब्याज सब्सिडी',
        'लचीला पुनर्भुगतान'
      ],
      'kn': [
        'ಸರಳ ಸಾಲ ಅನುಮೋದನೆ',
        'ಬಡ್ಡಿ ಸಬ್ಸಿಡಿ',
        'ಲವಚಿಕ್ ಪಾವತ'
      ],
      'mr': [
        'सोपे कर्ज मंजुरी',
        'व्याज अनुदान',
        'लवचीक परतफेड'
      ],
    },
    eligibility: {
      'en': 'All farmers including tenants.',
      'hi': 'सभी किसान पात्र हैं, किरायेदार सहित।',
      'kn': 'ಎಲ್ಲಾ ರೈತರು ಅರ್ಹರು, ಬಾಡಿಗೆ ರೈತರನ್ನು ಒಳಗೊಂಡಂತೆ.',
      'mr': 'सर्व शेतकरी पात्र आहेत, भाडेकरूंनासह.',
    },
  ),

  // ---------------------------------------------------------
  // 4. Soil Health Card
  // ---------------------------------------------------------
  Scheme(
    id: '4',
    name: {
      'en': 'Soil Health Card Scheme',
      'hi': 'मृदा स्वास्थ्य कार्ड योजना',
      'kn': 'ಮಣ್ಣು ಆರೋಗ್ಯ ಕಾರ್ಡ್ ಯೋಜನೆ',
      'mr': 'मृदा आरोग्य कार्ड योजना',
    },
    description: {
      'en': 'Provides farmers with soil testing and crop-wise advisory.',
      'hi': 'किसानों को मिट्टी परीक्षण और फसल सलाह दी जाती है।',
      'kn': 'ಕೃಷಿಕರಿಗೆ ಮಣ್ಣಿನ ಪರೀಕ್ಷೆ ಮತ್ತು ಬೆಳೆ ಸಲಹೆ ಒದಗిస్తుంది.',
      'mr': 'शेतकऱ्यांना माती परीक्षण आणि पिक सल्ला दिला जातो.',
    },
    officialLink: 'https://soilhealth.dac.gov.in/',
    tutorialLink:
        'https://www.youtube.com/results?search_query=Soil+Health+Card+scheme+how+to+apply',
    category: 'Agricultural Development',
    benefits: {
      'en': [
        'Free soil testing',
        'Crop-specific advice',
        'Higher productivity'
      ],
      'hi': [
        'फ्री मिट्टी परीक्षण',
        'फसल आधारित सुझाव',
        'उत्पादकता में वृद्धि'
      ],
      'kn': [
        'ಉಚಿತ ಮಣ್ಣು ಪರೀಕ್ಷೆ',
        'ಬೆಳೆ ಆಧಾರಿತ ಸಲಹೆ',
        'ಹೆಚ್ಚು ಉತ್ಪಾದನೆ'
      ],
      'mr': [
        'मोफत माती तपासणी',
        'पिकानुसार सल्ला',
        'उत्पादन वाढ'
      ],
    },
    eligibility: {
      'en': 'All farmers are eligible.',
      'hi': 'सभी किसान पात्र हैं।',
      'kn': 'ಎಲ್ಲಾ ರೈತರು ಅರ್ಹರು.',
      'mr': 'सर्व शेतकरी पात्र आहेत.',
    },
  ),

  // ---------------------------------------------------------
  // 5. National Mission for Sustainable Agriculture
  // ---------------------------------------------------------
  Scheme(
    id: '5',
    name: {
      'en': 'National Mission for Sustainable Agriculture',
      'hi': 'सतत कृषि हेतु राष्ट्रीय मिशन',
      'kn': 'ಸಸ್ಥಿರ ಕೃಷಿಗಾಗಿ ರಾಷ್ಟ್ರೀಯ ಮಿಷನ್',
      'mr': 'शाश्वत शेतीसाठी राष्ट्रीय मिशन',
    },
    description: {
      'en': 'Supports sustainable farming and resource management.',
      'hi': 'सतत कृषि और संसाधन प्रबंधन को बढ़ावा देता है।',
      'kn': 'ಸಸ್ಥಿರ ಕೃಷಿ ಮತ್ತು ಸಂಪನ್ಮೂಲ ನಿರ್ವಹಣೆಗೆ ಬೆಂಬಲ.',
      'mr': 'शाश्वत शेती आणि संसाधन व्यवस्थापनास समर्थन.',
    },
    officialLink: 'https://nmsa.dac.gov.in/',
    tutorialLink:
        'https://www.youtube.com/results?search_query=National+Mission+Sustainable+Agriculture',
    category: 'Agricultural Development',
    benefits: {
      'en': [
        'Subsidy on equipment',
        'Training programs',
        'Technical support'
      ],
      'hi': [
        'उपकरणों पर सब्सिडी',
        'प्रशिक्षण कार्यक्रम',
        'तकनीकी सहायता'
      ],
      'kn': [
        'ಉಪಕರಣಗಳ ಮೇಲೆ ಅನುದಾನ',
        'ತರಬೇತಿ ಕಾರ್ಯಕ್ರಮಗಳು',
        'ತಾಂತ್ರಿಕ ಬೆಂಬಲ'
      ],
      'mr': [
        'साधनांवर अनुदान',
        'प्रशिक्षण कार्यक्रम',
        'तांत्रिक मदत'
      ],
    },
    eligibility: {
      'en': 'Farmers using sustainable practices.',
      'hi': 'सतत कृषि करने वाले किसान पात्र हैं।',
      'kn': 'ಸಸ್ಥಿರ ಕೃಷಿ ಮಾಡುವ ರೈತರು ಅರ್ಹರು.',
      'mr': 'शाश्वत शेती करणारे शेतकरी पात्र आहेत.',
    },
  ),

];
