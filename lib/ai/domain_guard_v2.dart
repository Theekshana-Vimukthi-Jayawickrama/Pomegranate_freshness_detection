class DomainDecision {
  final bool inDomain;
  final double confidence; 
  final String hintEn;
  final String hintSi;
  final bool isQuestion;
  final bool shouldAskFollowUp;
  final List<String> matchedKeywords;

  DomainDecision({
    required this.inDomain,
    required this.confidence,
    required this.hintEn,
    required this.hintSi,
    required this.isQuestion,
    required this.shouldAskFollowUp,
    required this.matchedKeywords,
  });
}

// class DomainGuardV2 {
//   // English (common)
//   static const _en = [
//     "pomegranate",
//     "fruit",
//     "fresh",
//     "eat",
//     "ate",
//     "freshness",
//     "ripe",
//     "ripeness",
//     "rotten",
//     "spoiled",
//     "mold",
//     "smell",
//     "skin",
//     "peel",
//     "color",
//     "seed",
//     "arils",
//     "juice",
//     "close",
//     "far",
//     "quality",
//     "wrinkle",
//     "soft",
//     "hard",
//     "firm",
//     "heavy",
//     "weight",
//   ];

//   // Sinhala (native)
//   static const _si = [
//     "දෙළුම්",
//     "දෙලූම්",
//     "පලතුරු",
//     "නැවුම්",
//     "නරක",
//     "කුණු",
//     "මෝල්ඩ්",
//     "ගඳ",
//     "වර්ණ",
//     "පැහැ",
//     "බීජ",
//     "ලඟ",
//     "දුර",
//     "පැසුණු",
//     "පැසීම",
//     "මෘදු",
//     "තද",
//     "බර",
//   ];

//   // Singlish / roman Sinhala that people type in Sri Lanka
//   static const _sg = [
//     "delum",
//     "delumda",
//     "delum da",
//     "delum ekak",
//     "delum eka",
//     "meka delum",
//     "meeka delum",
//     "meka delu",
//     "meeka delu",
//     "me delum",
//     "eka delum",
//     "delum ne da",
//     "delum neda",
//     "hondai",
//     "hondada",
//     "hondada?",
//     "hari da",
//     "hariද",
//     "narakai",
//     "narakda",
//     "narak da",
//     "kunu",
//     "kunu da",
//     "fresh da",
//     "fresh da?",
//     "freshද",
//     "fresh neda",
//     "mold da",
//     "ganda",
//     "gandha",
//     "ganda da",
//   ];

//   static DomainDecision decide(String text) {
//     final t = text.toLowerCase().trim();

//     int hits = 0;
//     final matched = <String>[];

//     // English hits
//     for (final k in _en) {
//       if (t.contains(k)) {
//         hits++;
//         if (!matched.contains(k)) matched.add(k);
//       }
//     }

//     // Sinhala hits (do not lowercase Sinhala string)
//     for (final k in _si) {
//       if (text.contains(k)) {
//         hits++;
//         if (!matched.contains(k)) matched.add(k);
//       }
//     }

//     // Singlish hits
//     for (final k in _sg) {
//       if (t.contains(k)) {
//         hits++;
//         if (!matched.contains(k)) matched.add(k);
//       }
//     }

//     // Confidence
//     final confidence = hits >= 3 ? 0.9 : hits == 2 ? 0.75 : hits == 1 ? 0.6 : 0.0;
//     final inDomain = hits >= 1;

//     // Question detection (English heuristics + simple Sinhala question words)
//     final questionRegex = RegExp(r'^(is|are|do|does|did|how|why|what|when|where|can|could|should|will|would|who)\\b', caseSensitive: false);
//     final siQuestionWords = ['ඇයි', 'කොහොම', 'කොහොමද', 'කවුද', 'කවදා', 'කොහේ'];
//     final isSiQuestion = siQuestionWords.any((w) => text.contains(w));
//     final isQuestion = t.contains('?') || questionRegex.hasMatch(t) || isSiQuestion;

//     // Suggest asking a follow-up if it's in-domain but user didn't phrase a question
//     final shouldAskFollowUp = inDomain && !isQuestion;

//     return DomainDecision(
//       inDomain: inDomain,
//       confidence: confidence,
//       hintEn:
//       "Ask things like: Is it fresh? Why fresh? How to store? Any soft spots? Any mold/smell?",
//       hintSi:
//       "උදා: මේක නැවුම්ද? ඇයි නැවුම් කියන්නේ? ගබඩා කරන්නේ කොහොමද? මෘදු තැන්/මෝල්ඩ්/ගඳ තියෙනවද?",
//       isQuestion: isQuestion,
//       shouldAskFollowUp: shouldAskFollowUp,
//       matchedKeywords: matched,
//     );
//   }
// }

class DomainGuardV3 {
  // Same keyword lists as before
  static const _en = [
    "pomegranate","fruit","fresh","eat","ate","freshness","ripe","ripeness","rotten",
    "spoiled","mold","smell","skin","peel","color","seed","arils","juice","close",
    "far","quality","wrinkle","soft","hard","firm","heavy","weight",
  ];

  static const _si = [
    "දෙළුම්","දෙලූම්","පලතුරු","නැවුම්","නරක","කුණු","මෝල්ඩ්","ගඳ",
    "වර්ණ","පැහැ","බීජ","ලඟ","දුර","පැසුණු","පැසීම","මෘදු","තද","බර",
  ];

  static const _sg = [
    "delum","delumda","delum da","delum ekak","delum eka","meka delum","meeka delum",
    "meka delu","meeka delu","me delum","eka delum","delum ne da","delum neda",
    "hondai","hondada","hondada?","hari da","hariද","narakai","narakda","narak da",
    "kunu","kunu da","fresh da","fresh da?","freshද","fresh neda","mold da","ganda","gandha","ganda da"
  ];

  /// Decide if text is in-domain
  /// [hasPredictionContext] = true if user already uploaded a pomegranate image
  static DomainDecision decide(String text, {bool hasPredictionContext = false}) {
    final t = text.toLowerCase().trim();
    int hits = 0;
    final matched = <String>[];

    for (final k in _en) if (t.contains(k)) { hits++; matched.add(k); }
    for (final k in _si) if (text.contains(k)) { hits++; matched.add(k); }
    for (final k in _sg) if (t.contains(k)) { hits++; matched.add(k); }

    final confidence = hits >= 3 ? 0.9 : hits == 2 ? 0.75 : hits == 1 ? 0.6 : 0.0;

    // IN-DOMAIN if keyword hit OR prediction context exists
    final inDomain = hits >= 1 || hasPredictionContext;

    // Question detection (basic)
    final questionRegex = RegExp(r'^(is|are|do|does|did|how|why|what|when|where|can|could|should|will|would|who)\b', caseSensitive: false);
    final siQuestionWords = ['ඇයි','කොහොම','කොහොමද','කවුද','කවදා','කොහේ'];
    final isSiQuestion = siQuestionWords.any((w) => text.contains(w));
    final isQuestion = t.contains('?') || questionRegex.hasMatch(t) || isSiQuestion;

    // Follow-up suggestion if in-domain but user didn't ask question
    final shouldAskFollowUp = inDomain && !isQuestion;

    return DomainDecision(
      inDomain: inDomain,
      confidence: confidence,
      hintEn: "Ask things like: Is it fresh? Why fresh? How to store? Any soft spots? Any mold/smell?",
      hintSi: "උදා: මේක නැවුම්ද? ඇයි නැවුම් කියන්නේ? ගබඩා කරන්නේ කොහොමද? මෘදු තැන්/මෝල්ඩ්/ගඳ තියෙනවද?",
      isQuestion: isQuestion,
      shouldAskFollowUp: shouldAskFollowUp,
      matchedKeywords: matched,
    );
  }
}