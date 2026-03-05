class SafetyGuard {
  // Medical-related trigger keywords (English + Sinhala + Singlish)
  static const List<String> _medicalTriggers = [
    // English
    "medicine",
    "tablet",
    "pill",
    "drug",
    "antibiotic",
    "treatment",
    "dose",
    "dosage",
    "cure",
    "diagnose",
    "diagnosis",
    "prescription",
    "side effect",
    "side effects",
    "mg",
    "ml",
    "per day",
    "twice a day",
    "three times a day",

    // Sinhala
    "ඖෂධ",
    "බෙහෙත්",
    "ඖෂධය",
    "ප්‍රතිකාර",
    "මාත්‍රා",
    "රෝගය",
    "වෛද්‍ය",
    "ඖෂධ ලබාගන්න",
    "ඖෂධ ගන්න",

    // Singlish
    "beheth",
    "osadha",
    "prathikara",
    "dose eka",
    "roge",
    "doctor kenek",
  ];

  /// Check if user message contains medical-related content
  static bool isMedicalRequest(String text) {
    final t = text.toLowerCase().trim();

    for (final keyword in _medicalTriggers) {
      final pattern = r'\b' + RegExp.escape(keyword.toLowerCase()) + r'\b';
      final regex = RegExp(pattern);

      if (regex.hasMatch(t)) {
        return true;
      }
    }
    return false;
  }

  /// Return refusal message based on selected language
  static String medicalRefusal(String lang) {
    switch (lang) {
      case "si":
        return "මට වෛද්‍ය ප්‍රතිකාර හෝ ඖෂධ පිළිබඳ උපදෙස් ලබාදීමට නොහැක. "
            "ඔබට අසනීප ලක්ෂණ තිබේ නම් කරුණාකර සුදුසු වෛද්‍යවරයෙකුගෙන් උපදෙස් ලබාගන්න. "
            "මට දෙළුම් ගුණාත්මකභාවය, නැවුම්භාවය සහ ගබඩා කිරීම පිළිබඳ සාමාන්‍ය උපදෙස් ලබාදිය හැක.";

      case "sg": // Singlish
        return "Mama beheth, dose, treatment wage dewal gena medical advice denna ba. "
            "Oya ta asaneepa nam doctor kenekwa hamu wenna. "
            "Mama pomegranate freshness, quality saha storage gana help karanna puluwan.";

      default: // English
        return "I can’t provide medical diagnosis or medicine/treatment advice. "
            "If someone feels unwell, please consult a qualified healthcare professional. "
            "I can help with general pomegranate freshness, quality, or storage guidance.";
    }
  }
}