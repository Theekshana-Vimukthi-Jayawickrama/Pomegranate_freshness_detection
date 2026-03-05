// import 'pipeline_predictor.dart';

// /// Human-friendly XAI builder
// /// Converts model outputs into explanations that normal users understand
// class XaiBuilder {
//   /// Build user-friendly explanation
//   static String buildHuman({
//     required PipelineResult r,
//     required String lang, // "en" or "si"
//   }) {
//     final a = r.a;
//     final b = r.b;
//     final f = r.f;

//     // -------------------------
//     // No Model A result
//     // -------------------------
//     if (a == null) {
//       return _t(
//         lang,
//         si:
//         "මෙම රූපයෙන් දෙළුම් ලක්ෂණ පැහැදිලි නැහැ. ලඟින්, පැහැදිලි ආලෝකයකින් රූපයක් ගන්න.",
//         en:
//         "Pomegranate cues are not clear in this image. Try a closer photo with better lighting.",
//       );
//     }

//     // -------------------------
//     // Stage: Not Pomegranate
//     // -------------------------
//     if (r.stage == PipelineStage.notPomegranate) {
//       return _t(
//         lang,
//         si:
//         "මෙම රූපයේ දෙළුම් නොමැති විය හැක. දෙළුම් එක පින්තූරයේ මධ්‍යයේ තබා, ලඟින් රූපයක් ගන්න.",
//         en:
//         "This image may not contain a pomegranate. Center the fruit and take a closer photo.",
//       );
//     }

//     // -------------------------
//     // Stage: Far / Quality issue
//     // -------------------------
//     if (r.stage == PipelineStage.far) {
//       return _t(
//         lang,
//         si:
//         "රූපය දුරයි හෝ අපැහැදිලි. දෙළුම් එක පින්තූරයේ වැඩි ප්‍රමාණයක් පුරවෙන විදිහට ලඟින් ගත්තොත් ප්‍රතිඵල වඩා නිවැරදි වේ.",
//         en:
//         "The image is too far or unclear. Take a closer shot so the fruit fills most of the frame.",
//       );
//     }

//     // -------------------------
//     // Stage: Freshness Done
//     // -------------------------
//     if (b != null && f != null && r.stage == PipelineStage.closeFreshnessDone) {
//       final isFresh = f.label.toLowerCase() == "fresh";

//       if (lang == "si") {
//         return isFresh
//             ? """
// ✅ **මෙම දෙළුම් එක නෑවුම් ලෙස පෙනේ**

// සාමාන්‍යයෙන් නෑවුම් දෙළුම් වල:
// • පිටත පොත්ත **තද** (wrinkled නොවීම)
// • වර්ණය **සමාන** වීම (කළු/කහ පැල්ලම් අඩු)
// • පැහැදිලි, ගැටළු අඩු පිටත ආකෘතිය

// 🔎 **ඇත්තටම තහවුරු කරන්න:**
// • අතට ගත්තොත් **තදද?**
// • මෘදු තැන් හෝ ලීක් වීම තියෙනවාද?
// • මෝල්ඩ් හෝ දුර්ගන්ධයක් තියෙනවාද?

// ℹ️ සටහන: මේ ප්‍රතිඵලය රූපය මත පදනම්වයි.
// """
//             : """
// ❌ **මෙම දෙළුම් එක නෑවුම් නොවිය හැක**

// සාමාන්‍යයෙන් නෑවුම් නොවන දෙළුම් වල:
// • **මෘදු තැන්**
// • **කළු/කහ පැල්ලම්**
// • පිටත පොත්ත හැකිළීම (wrinkles)
// • ලීක් වීම හෝ මෝල්ඩ් ලක්ෂණ

// 🔎 **ඇත්තටම තහවුරු කරන්න:**
// • මෘදු තැන් තිබේද?
// • දුර්ගන්ධයක් (fermented smell) තිබේද?
// • මෝල්ඩ් දකින්න ලැබේද?

// ℹ️ සටහන: හොඳ ආලෝකය සහ ලඟින් ගත් රූප accuracy වැඩි කරයි.
// """;
//       }

//       // -------------------------
//       // English
//       // -------------------------
//       return isFresh
//           ? """
// ✅ **This pomegranate looks FRESH**

// Fresh pomegranates usually show:
// • **Firm skin** (not wrinkled)
// • **More even color** (fewer dark/yellow patches)
// • A clean, solid outer surface

// 🔎 **To confirm in real life:**
// • Does it feel **heavy for its size**?
// • Any **soft spots** or leaks?
// • Any **mold or sour smell**?

// ℹ️ Note: This result is based on visual cues from the image.
// """
//           : """
// ❌ **This pomegranate may NOT be fresh**

// Less fresh pomegranates often show:
// • **Soft spots**
// • **Dark or yellow patches**
// • **Wrinkled skin**
// • Signs of **mold or decay**

// 🔎 **To confirm in real life:**
// • Press gently — any soft areas?
// • Any leaking juice?
// • Any fermented or sour smell?

// ℹ️ Tip: A closer, well-lit photo improves accuracy.
// """;
//     }

//     // -------------------------
//     // Fallback
//     // -------------------------
//     return _t(
//       lang,
//       si: "මෙම අවස්ථාවේ XAI විස්තර සම්පූර්ණ නැහැ.",
//       en: "XAI details are not fully available for this run.",
//     );
//   }

//   // --------------------------------------------------
//   // Language helper
//   // --------------------------------------------------
//   static String _t(
//       String lang, {
//         required String si,
//         required String en,
//       }) {
//     return lang == "si" ? si : en;
//   }
// }
