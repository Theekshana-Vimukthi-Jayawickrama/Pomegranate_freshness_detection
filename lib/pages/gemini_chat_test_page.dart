// import 'package:flutter/material.dart';
//
// import '../ai/net_check.dart';
// import '../ai/domain_guard.dart';
// import '../ai/gemini_client.dart';
// import '../ai/gemini_prompt_builder.dart';
//
// enum ChatRole { user, model }
//
// class ChatMsg {
//   final ChatRole role;
//   final String text;
//   ChatMsg(this.role, this.text);
// }
//
// class GeminiChatTestPage extends StatefulWidget {
//   const GeminiChatTestPage({super.key});
//
//   @override
//   State<GeminiChatTestPage> createState() => _GeminiChatTestPageState();
// }
//
// class _GeminiChatTestPageState extends State<GeminiChatTestPage> {
//   static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
//
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scroll = ScrollController();
//
//   String lang = "en"; // "en" or "si"
//   String status = "Ready";
//   bool loading = false;
//
//   late final GeminiClient gemini = GeminiClient(
//     apiKey: apiKey,
//     modelName: "gemini-2.5-flash",
//   );
//
//   // For test page: we don’t have real model results,
//   // so we create a dummy result structure.
//   Map<String, dynamic> dummyPipelineResult = {
//     "stage": "closeFreshnessDone",
//     "modelA": {"label": "pomegranate", "score": 0.92, "threshold": 0.80},
//     "modelB": {"label": "close", "prob": 0.71, "threshold": 0.28},
//     "freshness": {"label": "fresh", "freshProb": 0.78, "nonFreshProb": 0.22},
//     "xai": "Decisions are threshold-based; lighting/blur can affect scores."
//   };
//
//   final List<ChatMsg> messages = [];
//
//   bool get _keyConfigured => apiKey.trim().isNotEmpty;
//
//   String _welcome() {
//     if (lang == "si") {
//       return "මෙය Gemini chat test එකක්. දෙළුම් පිළිබඳ ප්‍රශ්න පමණක් අසන්න.";
//     }
//     return "This is a Gemini chat test. Ask only pomegranate-related questions.";
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     messages.add(ChatMsg(ChatRole.model, _welcome()));
//   }
//
//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scroll.hasClients) {
//         _scroll.animateTo(
//           _scroll.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void _clearChat() {
//     setState(() {
//       messages
//         ..clear()
//         ..add(ChatMsg(ChatRole.model, _welcome()));
//       status = "Ready";
//     });
//   }
//
//   Future<void> _send() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//
//     setState(() {
//       messages.add(ChatMsg(ChatRole.user, text));
//       _controller.clear();
//       loading = true;
//       status = "Checking internet...";
//     });
//     _scrollToBottom();
//
//     // 1) internet check
//     final hasNet = await NetCheck.hasInternet();
//     if (!hasNet) {
//       setState(() {
//         loading = false;
//         status = "❌ No internet";
//         messages.add(ChatMsg(
//           ChatRole.model,
//           lang == "si"
//               ? "අන්තර්ජාලය නොමැත. Chat සේවාවට අන්තර්ජාලය අවශ්‍යයි."
//               : "No internet connection. Chat needs internet access.",
//         ));
//       });
//       _scrollToBottom();
//       return;
//     }
//
//     // 2) key check
//     if (!_keyConfigured) {
//       setState(() {
//         loading = false;
//         status = "❌ Key missing";
//         messages.add(ChatMsg(
//           ChatRole.model,
//           "GEMINI_API_KEY missing.\nRun:\nflutter run --dart-define=GEMINI_API_KEY=YOUR_KEY",
//         ));
//       });
//       _scrollToBottom();
//       return;
//     }
//
//     // 3) domain guard: only pomegranate questions
//     if (!DomainGuard.isPomegranateQuestion(text)) {
//       setState(() {
//         loading = false;
//         status = "Out of scope";
//         messages.add(ChatMsg(
//           ChatRole.model,
//           lang == "si"
//               ? "ඔබට දෙළුම් පිළිබඳ ප්‍රශ්න පමණක් අසන්න පුළුවන්."
//               : "Please ask only pomegranate-related questions.",
//         ));
//       });
//       _scrollToBottom();
//       return;
//     }
//
//     setState(() => status = "Calling Gemini...");
//
//     try {
//       // Create strict prompt
//       final prompt = GeminiPromptBuilder.build(
//         language: lang,
//         pipelineResult: dummyPipelineResult,
//         userQuestion: text,
//       );
//
//       // We send ONE message prompt each time (simple + reliable).
//       final contents = [
//         {
//           "role": "user",
//           "parts": [{"text": prompt}]
//         }
//       ];
//
//       final reply = await gemini.generate(
//         contents: contents,
//         temperature: 0.3,
//         maxOutputTokens: 512,
//       );
//
//       setState(() {
//         messages.add(ChatMsg(ChatRole.model, reply));
//         loading = false;
//         status = "✅ Reply received";
//       });
//     } catch (e) {
//       setState(() {
//         loading = false;
//         status = "❌ Gemini error";
//         messages.add(ChatMsg(ChatRole.model, "Error: $e"));
//       });
//     }
//
//     _scrollToBottom();
//   }
//
//   Widget _bubble(ChatMsg m) {
//     final isUser = m.role == ChatRole.user;
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.all(10),
//         constraints: const BoxConstraints(maxWidth: 340),
//         decoration: BoxDecoration(
//           color: isUser ? Colors.blue.shade100 : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Text(m.text),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final canSend = !loading;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Gemini Chat Test (Pomegranate-only)"),
//         actions: [
//           IconButton(
//             onPressed: loading ? null : _clearChat,
//             icon: const Icon(Icons.delete_outline),
//             tooltip: "Clear chat",
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Status card + language selector
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "API Key: ${_keyConfigured ? "✅ Found" : "❌ Missing"}",
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(status),
//                       ],
//                     ),
//                   ),
//                   DropdownButton<String>(
//                     value: lang,
//                     items: const [
//                       DropdownMenuItem(value: "en", child: Text("English")),
//                       DropdownMenuItem(value: "si", child: Text("සිංහල")),
//                     ],
//                     onChanged: (v) {
//                       if (v == null) return;
//                       setState(() {
//                         lang = v;
//                         messages.add(ChatMsg(ChatRole.model, _welcome()));
//                       });
//                       _scrollToBottom();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 12),
//             if (loading) const LinearProgressIndicator(),
//             const SizedBox(height: 12),
//
//             Expanded(
//               child: ListView.builder(
//                 controller: _scroll,
//                 itemCount: messages.length,
//                 itemBuilder: (context, i) => _bubble(messages[i]),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     enabled: canSend,
//                     decoration: InputDecoration(
//                       hintText: lang == "si"
//                           ? "දෙළුම් ගැන අහන්න..."
//                           : "Ask about pomegranates...",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onSubmitted: (_) => canSend ? _send() : null,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: canSend ? _send : null,
//                   icon: loading
//                       ? const SizedBox(
//                     width: 18,
//                     height: 18,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                       : const Icon(Icons.send),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 8),
//
//             Text(
//               "Run:\nflutter run --dart-define=GEMINI_API_KEY=YOUR_KEY",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
