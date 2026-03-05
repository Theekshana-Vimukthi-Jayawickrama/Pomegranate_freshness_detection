// import 'package:flutter/material.dart';
// import '../ai/net_check.dart';
// import '../ai/gemini_client.dart';
//
// class GeminiConnectionTestPage extends StatefulWidget {
//   const GeminiConnectionTestPage({super.key});
//
//   @override
//   State<GeminiConnectionTestPage> createState() => _GeminiConnectionTestPageState();
// }
//
// class _GeminiConnectionTestPageState extends State<GeminiConnectionTestPage> {
//   String status = "Press the button to test Gemini connection";
//   String? reply;
//   bool loading = false;
//
//   // API key comes from build/run:
//   // flutter run --dart-define=GEMINI_API_KEY=AIza...
//   static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
//
//   Future<void> testConnection() async {
//     setState(() {
//       loading = true;
//       reply = null;
//       status = "Checking internet...";
//     });
//
//     // 1) Internet check
//     final hasNet = await NetCheck.hasInternet();
//     if (!hasNet) {
//       setState(() {
//         loading = false;
//         status = "❌ No internet connection";
//       });
//       return;
//     }
//
//     // 2) API key check
//     if (apiKey.trim().isEmpty) {
//       setState(() {
//         loading = false;
//         status = "❌ GEMINI_API_KEY is missing.\nRun with --dart-define=GEMINI_API_KEY=YOUR_KEY";
//       });
//       return;
//     }
//
//     // 3) Call Gemini
//     setState(() => status = "Calling Gemini...");
//
//     try {
//       final gemini = GeminiClient(
//         apiKey: apiKey,
//         modelName: "gemini-2.5-flash",
//       );
//
//       final r = await gemini.ping();
//
//       setState(() {
//         loading = false;
//         reply = r;
//         status = "✅ Gemini connected successfully";
//       });
//     } catch (e) {
//       setState(() {
//         loading = false;
//         status = "❌ Gemini connection failed:\n$e";
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final keyConfigured = apiKey.trim().isNotEmpty;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Gemini Connection Test")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "API Key status: ${keyConfigured ? "✅ Found" : "❌ Missing"}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(status),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               onPressed: loading ? null : testConnection,
//               icon: const Icon(Icons.wifi_tethering),
//               label: const Text("Test Gemini Connection"),
//             ),
//             const SizedBox(height: 12),
//             if (loading) const LinearProgressIndicator(),
//             const SizedBox(height: 12),
//             if (reply != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.green.shade200),
//                 ),
//                 child: Text(
//                   "Gemini reply:\n$reply",
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             const Spacer(),
//             Text(
//               "Run command:\nflutter run --dart-define=GEMINI_API_KEY=YOUR_KEY",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade700),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

