// import '../ai/net_check.dart';
// import '../ai/gemini_client.dart';
// import '../ai/xai_builder_human.dart';
// import '../ai/pipeline_predictor.dart';
// import '../ai/domain_guard_v2.dart';
// import '../ai/text_sanitize.dart';

// class PomegranateAssistant {
//   final GeminiClient gemini;

//   PomegranateAssistant({required this.gemini});

//   String _offline(String lang) {
//     if (lang == "si") {
//       return "අන්තර්ජාලය නොමැත. Chat සේවාව භාවිතා කිරීමට අන්තර්ජාල සම්බන්ධතාව අවශ්‍යයි.";
//     }
//     if (lang == "sg") {
//       return "Internet naha. Chat use karanna internet one.";
//     }
//     return "No internet connection. The chat feature needs internet access.";
//   }

//   String _locked(String lang) {
//     if (lang == "si") {
//       return "Chat ලබාගැනීමට පෙර ✅ දෙළුම් + ✅ ලඟ + ✅ freshness ප්‍රතිඵල ලැබිය යුතුයි.";
//     }
//     if (lang == "sg") {
//       return "Chat unlock wenne ✅ delum + ✅ close + ✅ freshness result awama witharai.";
//     }
//     return "Chat unlocks only after ✅ pomegranate + ✅ close + ✅ freshness result.";
//   }

//   String _notDomain(String lang, DomainDecision d) {
//     if (lang == "si") {
//       return "ඔබට දෙළුම් පිළිබඳ ප්‍රශ්න පමණක් අසන්න පුළුවන්.\n\nඋදව්:\n${d.hintSi}";
//     }
//     if (lang == "sg") {
//       return "Delum related prashna witharak ahanna.\n\nTry:\n${d.hintEn}";
//     }
//     return "Please ask only pomegranate-related questions.\n\nTry:\n${d.hintEn}";
//   }

//   String _systemInstruction(String lang) {
//     if (lang == "si") {
//       return """
// ඔබ "දෙළුම් සහායකයෙකි".
// දෙළුම් (නැවුම්භාවය/ගුණාත්මකභාවය/ගබඩා කිරීම/වෙළඳපොළ ගුණාංග) පිළිබඳ ප්‍රශ්නවලට සරලව, ප්‍රයෝජනවත් ලෙස පිළිතුරු දෙන්න.

// නීති:
// - ඖෂධ/medicine/වෛද්‍ය ප්‍රතිකාර/දෝෂ නිරණය (diagnosis) උපදෙස් දෙන්න එපා.
// - සෞඛ්‍ය ප්‍රශ්න නම් සාමාන්‍ය food-safety උපදෙස් පමණක්; වෘත්තීය උපදෙස් ලබාගන්න කියන්න.
// - සාක්ෂි නැති දේ invent කරන්න එපා.
// - මෙහි model results + human XAI + සාමාන්‍ය දෙළුම් දැනුම භාවිතා කර පිළිතුරු දෙන්න.
// - Markdown formatting (**, bullets) භාවිතා කරන්න එපා. Plain text.
// """;
//     }

//     if (lang == "sg") {
//       return """
// You are a "Pomegranate Assistant" inside a mobile app.
// Reply in SIMPLE English. If helpful, you may include a few roman Sinhala words (delum, hondai, narakai), but keep it natural.

// Rules:
// - Do NOT recommend medicines, treatments, dosages, or diagnosis.
// - If asked medical/health, give only general food-safety guidance and suggest consulting a qualified professional.
// - Do NOT invent facts without evidence.
// - Use model results + human XAI + general pomegranate knowledge.
// - Avoid markdown formatting (**bold**, markdown bullets). Use plain text.
// """;
//     }

//     return """
// You are a "Pomegranate Assistant".
// Reply in SIMPLE English for farmers/buyers/sellers.

// Rules:
// - Do NOT recommend medicines, treatments, dosages, or diagnosis.
// - If asked medical/health, give only general food-safety guidance and suggest consulting a qualified professional.
// - Do NOT invent facts without evidence.
// - Use model results + human XAI + general pomegranate knowledge.
// - Avoid markdown formatting (**bold**, markdown bullets). Use plain text.
// """;
//   }

//   Future<String> answer({
//     required String userQuestion,
//     required PipelineResult pipelineResult,
//     required String uiLang, // "en" | "si" | "sg" selected by user
//     required List<Map<String, dynamic>> historyContents,
//   }) async {
//     // 1) Internet
//     final ok = await NetCheck.hasInternet();
//     if (!ok) return _offline(uiLang);

//     // 2) Domain decision
//     final d = DomainGuardV2.decide(userQuestion);
//     if (!d.inDomain) return _notDomain(uiLang, d);

//     // 3) Pipeline stage gate
//     if (pipelineResult.stage != PipelineStage.closeFreshnessDone) {
//       return _locked(uiLang);
//     }

//     // 4) Human XAI
//     final xaiHuman = XaiBuilderHuman.buildHuman(r: pipelineResult, lang: uiLang);

//     // 5) Context block
//     final sys = _systemInstruction(uiLang);

//     final contextBlock = """
// SYSTEM:
// $sys

// MODEL RESULTS (from THIS image):
// - ModelA: score=${pipelineResult.a?.score} thr=${pipelineResult.a?.threshold} label=${pipelineResult.a?.label}
// - ModelB: prob=${pipelineResult.b?.prob} thr=${pipelineResult.b?.threshold} label=${pipelineResult.b?.label}
// - Freshness: label=${pipelineResult.f?.label} fresh=${pipelineResult.f?.freshProb} non_fresh=${pipelineResult.f?.nonFreshProb}

// HUMAN XAI (use for explanation):
// $xaiHuman

// GUIDE FOR ANSWERS:
// - If user asks “why fresh / features?”, explain with common cues:
//   color, firmness, wrinkles, soft spots, dark patches, mold, bad smell, leakage, weight.
// - Keep it practical for farmer/buyer/seller.
// - If something cannot be confirmed from image/results, say clearly “not sure from this image”.
// """;

//     // Gemini contents
//     final contents = <Map<String, dynamic>>[
//       {"role": "user", "parts": [{"text": contextBlock}]},
//       ...historyContents,
//       {"role": "user", "parts": [{"text": userQuestion}]},
//     ];

//     final raw = await gemini.generate(
//       contents: contents,
//       temperature: 0.3,
//       maxOutputTokens: 512,
//     );

//     // ✅ Remove stars / markdown
//     return TextSanitize.stripMarkdown(raw);
//   }
// }

import '../ai/net_check.dart';
import '../ai/gemini_client.dart';
import '../ai/xai_builder_human.dart';
import '../ai/pipeline_predictor.dart';
import '../ai/domain_guard_v2.dart';
import '../ai/text_sanitize.dart';

class PomegranateAssistant {
  final GeminiClient gemini;

  PomegranateAssistant({required this.gemini});

  // Offline messages
  String _offline(String lang) {
    if (lang == "si") return "අන්තර්ජාලය නොමැත. Chat සේවාව භාවිතා කිරීමට අන්තර්ජාල සම්බන්ධතාව අවශ්‍යයි.";
    if (lang == "sg") return "Internet naha. Chat use karanna internet one.";
    return "No internet connection. The chat feature needs internet access.";
  }

  // Locked messages if pipeline not ready
  String _locked(String lang) {
    if (lang == "si") return "Chat ලබාගැනීමට පෙර ✅ දෙළුම් + ✅ ලඟ + ✅ freshness ප්‍රතිඵල ලැබිය යුතුයි.";
    if (lang == "sg") return "Chat unlock wenne ✅ delum + ✅ close + ✅ freshness result awama witharai.";
    return "Chat unlocks only after ✅ pomegranate + ✅ close + ✅ freshness result.";
  }

  // Not domain / keyword guard message
  String _notDomain(String lang, DomainDecision d) {
    if (lang == "si") return "ඔබට දෙළුම් පිළිබඳ ප්‍රශ්න පමණක් අසන්න පුළුවන්.\n\nඋදව්:\n${d.hintSi}";
    if (lang == "sg") return "Delum related prashna witharak ahanna.\n\nTry:\n${d.hintEn}";
    return "Please ask only pomegranate-related questions.\n\nTry:\n${d.hintEn}";
  }

  // System instruction for Gemini
  String _systemInstruction(String lang) {
    if (lang == "si") {
      return """
  ඔබ "දෙළුම් සහායකයෙකි".
  දෙළුම් (නැවුම්භාවය/ගුණාත්මකභාවය/ගබඩා කිරීම/වෙළඳපොළ ගුණාංග) පිළිබඳ ප්‍රශ්නවලට සරලව, ප්‍රයෝජනවත් ලෙස පිළිතුරු දෙන්න.

  නීති:
  - ඖෂධ/medicine/වෛද්‍ය ප්‍රතිකාර/දෝෂ නිරණය (diagnosis) උපදෙස් දෙන්න එපා.
  - සෞඛ්‍ය ප්‍රශ්න නම් සාමාන්‍ය food-safety උපදෙස් පමණක්; වෘත්තීය උපදෙස් ලබාගන්න කියන්න.
  - සාක්ෂි නැති දේ invent කරන්න එපා.
  - මෙහි model results + human XAI + සාමාන්‍ය දෙළුම් දැනුම භාවිතා කර පිළිතුරු දෙන්න.
  - Markdown formatting (**, bullets) භාවිතා කරන්න එපා. Plain text.
  """;
      }
      if (lang == "sg") {
        return """
  You are a "Pomegranate Assistant" inside a mobile app.
  Reply in SIMPLE English. If helpful, you may include a few roman Sinhala words (delum, hondai, narakai), but keep it natural.

  Rules:
  - Do NOT recommend medicines, treatments, dosages, or diagnosis.
  - If asked medical/health, give only general food-safety guidance and suggest consulting a qualified professional.
  - Do NOT invent facts without evidence.
  - Use model results + human XAI + general pomegranate knowledge.
  - Avoid markdown formatting (**bold**, bullets). Use plain text.
  """;
      }
      return """
  You are a "Pomegranate Assistant".
  Reply in SIMPLE English for farmers/buyers/sellers.

  Rules:
  - Do NOT recommend medicines, treatments, dosages, or diagnosis.
  - If asked medical/health, give only general food-safety guidance and suggest consulting a qualified professional.
  - Do NOT invent facts without evidence.
  - Use model results + human XAI + general pomegranate knowledge.
  - Avoid markdown formatting (**bold**, bullets). Use plain text.
  """;
  }

  /// Main answer function
  Future<String> answer({
    required String userQuestion,
    required PipelineResult pipelineResult,
    required String uiLang, // "en" | "si" | "sg"
    required List<Map<String, dynamic>> historyContents,
  }) async {

    // 1️⃣ Internet check
    final ok = await NetCheck.hasInternet();
    if (!ok) return _offline(uiLang);

    // 2️⃣ Context-aware Domain Guard
    final hasPredictionContext = pipelineResult.stage == PipelineStage.closeFreshnessDone;
    final d = DomainGuardV3.decide(userQuestion, hasPredictionContext: hasPredictionContext);

    if (!d.inDomain) return _notDomain(uiLang, d);

    // 3️⃣ Pipeline stage check
    if (pipelineResult.stage != PipelineStage.closeFreshnessDone) return _locked(uiLang);

    // 4️⃣ Human XAI explanation
    final xaiHuman = XaiBuilderHuman.buildHuman(r: pipelineResult, lang: uiLang);

    // 5️⃣ System instructions
    final sys = _systemInstruction(uiLang);

    final contextBlock = """
  SYSTEM:
  $sys

  MODEL RESULTS (from THIS image):
  - ModelB: prob=${pipelineResult.b?.prob} thr=${pipelineResult.b?.threshold} label=${pipelineResult.b?.label}
  - Freshness: label=${pipelineResult.f?.label} fresh=${pipelineResult.f?.freshProb} non_fresh=${pipelineResult.f?.nonFreshProb}

  HUMAN XAI (use for explanation):
  $xaiHuman

  GUIDE FOR ANSWERS:
  - If user asks “why fresh / features?”, explain with common cues:
    color, firmness, wrinkles, soft spots, dark patches, mold, bad smell, leakage, weight.
  - Keep it practical for farmer/buyer/seller.
  - If something cannot be confirmed from image/results, say clearly “not sure from this image”.
  """;

    // 6️⃣ Prepare Gemini contents
    final contents = <Map<String, dynamic>>[
      {"role": "user", "parts": [{"text": contextBlock}]},
      ...historyContents,
      {"role": "user", "parts": [{"text": userQuestion}]},
    ];

    // 7️⃣ Call Gemini
    final raw = await gemini.generate(
      contents: contents,
      temperature: 0.3,
      maxOutputTokens: 512,
    );

    // 8️⃣ Clean Markdown if any
    return TextSanitize.stripMarkdown(raw);
  }
}