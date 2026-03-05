// import 'package:flutter/material.dart';
//
// import '../ai/pomegranate_assistant.dart';
// import '../ai/pipeline_predictor.dart';
// import 'chat_models.dart';
//
// class ChatLang {
//   final String code; // "en" | "si" | "sg"
//   final String label;
//   final String title;
//   const ChatLang(this.code, this.label, this.title);
// }
//
// class PomegranateChatPanel extends StatefulWidget {
//   final PipelineResult pipelineResult;
//   final PomegranateAssistant assistant;
//
//   const PomegranateChatPanel({
//     super.key,
//     required this.pipelineResult,
//     required this.assistant,
//   });
//
//   @override
//   State<PomegranateChatPanel> createState() => _PomegranateChatPanelState();
// }
//
// class _PomegranateChatPanelState extends State<PomegranateChatPanel> {
//   final _controller = TextEditingController();
//   final _scroll = ScrollController();
//
//   ChatLang? selectedLang; // ✅ no default
//   bool sending = false;
//
//   final List<ChatMessage> messages = [];
//
//   static const langs = <ChatLang>[
//     ChatLang("en", "English", "Pomegranate Chat"),
//     ChatLang("si", "සිංහල", "දෙළුම් Chat"),
//     ChatLang("sg", "Singlish", "Delum Chat"),
//   ];
//
//   List<Map<String, dynamic>> _buildGeminiHistory() {
//     final out = <Map<String, dynamic>>[];
//     for (final m in messages) {
//       if (m.role == ChatRole.user) {
//         out.add({"role": "user", "parts": [{"text": m.text}]});
//       } else if (m.role == ChatRole.model) {
//         out.add({"role": "model", "parts": [{"text": m.text}]});
//       }
//     }
//     return out;
//   }
//
//   String _welcome(String lang) {
//     if (lang == "si") {
//       return "ඔබට දෙළුම් පිළිබඳ ප්‍රශ්න අසන්න පුළුවන්. (මෙම රූපයේ ප්‍රතිඵල මත පදනම්ව පිළිතුරු දේ.)";
//     }
//     if (lang == "sg") {
//       return "Delum related prashna ahanna puluwan. (Me image results walata adala widiyata reply denawa.)";
//     }
//     return "You can ask pomegranate questions. (I answer using this image’s results.)";
//   }
//
//   Future<void> _ensureLangSelected() async {
//     if (selectedLang != null) return;
//
//     final picked = await showModalBottomSheet<ChatLang>(
//       context: context,
//       builder: (ctx) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(14),
//                 child: Text(
//                   "Select Chat Language",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               for (final l in langs)
//                 ListTile(
//                   title: Text(l.label),
//                   onTap: () => Navigator.pop(ctx, l),
//                 ),
//               const SizedBox(height: 6),
//             ],
//           ),
//         );
//       },
//     );
//
//     if (picked == null) return;
//
//     setState(() {
//       selectedLang = picked;
//       messages.clear();
//       messages.add(ChatMessage(role: ChatRole.model, text: _welcome(picked.code)));
//     });
//   }
//
//   void _resetChat() {
//     setState(() {
//       selectedLang = null;
//       messages.clear();
//       _controller.clear();
//     });
//   }
//
//   Future<void> _send() async {
//     await _ensureLangSelected();
//     if (selectedLang == null) return;
//
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//
//     setState(() {
//       sending = true;
//       messages.add(ChatMessage(role: ChatRole.user, text: text));
//       _controller.clear();
//     });
//
//     try {
//       final reply = await widget.assistant.answer(
//         userQuestion: text,
//         pipelineResult: widget.pipelineResult,
//         uiLang: selectedLang!.code,
//         historyContents: _buildGeminiHistory(),
//       );
//
//       setState(() {
//         messages.add(ChatMessage(role: ChatRole.model, text: reply));
//         sending = false;
//       });
//     } catch (e) {
//       setState(() {
//         messages.add(ChatMessage(role: ChatRole.model, text: "Error: $e"));
//         sending = false;
//       });
//     }
//
//     await Future.delayed(const Duration(milliseconds: 50));
//     if (_scroll.hasClients) {
//       _scroll.animateTo(
//         _scroll.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final enabled = widget.pipelineResult.stage == PipelineStage.closeFreshnessDone;
//     final title = selectedLang?.title ?? "Select Language to Chat";
//
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade300),
//         color: Colors.grey.shade50,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header row: title + choose language + reset
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               TextButton.icon(
//                 onPressed: sending ? null : _ensureLangSelected,
//                 icon: const Icon(Icons.language),
//                 label: Text(selectedLang?.label ?? "Choose"),
//               ),
//               IconButton(
//                 tooltip: "Reset chat",
//                 onPressed: sending
//                     ? null
//                     : () async {
//                   _resetChat();
//                   await _ensureLangSelected();
//                 },
//                 icon: const Icon(Icons.restart_alt),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//
//           if (!enabled)
//             Text(
//               selectedLang?.code == "si"
//                   ? "Chat ලබාගැනීමට පෙර ✅ දෙළුම් + ✅ ලඟ + ✅ freshness ප්‍රතිඵල ලැබිය යුතුයි."
//                   : (selectedLang?.code == "sg")
//                   ? "Chat unlock wenne ✅ delum + ✅ close + ✅ freshness result awama witharai."
//                   : "Chat unlocks only after ✅ pomegranate + ✅ close + ✅ freshness result.",
//               style: TextStyle(color: Colors.orange.shade800),
//             ),
//
//           const SizedBox(height: 8),
//
//           // Messages
//           SizedBox(
//             height: 220,
//             child: ListView.builder(
//               controller: _scroll,
//               itemCount: messages.length,
//               itemBuilder: (context, i) {
//                 final m = messages[i];
//                 final isUser = m.role == ChatRole.user;
//
//                 return Align(
//                   alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding: const EdgeInsets.all(10),
//                     constraints: const BoxConstraints(maxWidth: 320),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.blue.shade100 : Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: Text(m.text),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           // Input row
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   enabled: enabled && !sending,
//                   decoration: InputDecoration(
//                     hintText: selectedLang?.code == "si"
//                         ? "දෙළුම් ගැන අහන්න..."
//                         : (selectedLang?.code == "sg")
//                         ? "Delum gana ahanna..."
//                         : "Ask about this pomegranate...",
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onSubmitted: (_) => _send(),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 onPressed: (enabled && !sending) ? _send : null,
//                 icon: sending
//                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
//                     : const Icon(Icons.send),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../ai/pomegranate_assistant.dart';
import '../ai/pipeline_predictor.dart';
import 'chat_models.dart';

class ChatLang {
  final String code; // "en" | "si" | "sg"
  final String label;
  final String title;
  const ChatLang(this.code, this.label, this.title);
}

class PomegranateChatPanel extends StatefulWidget {
  final PipelineResult pipelineResult;
  final PomegranateAssistant assistant;

  const PomegranateChatPanel({
    super.key,
    required this.pipelineResult,
    required this.assistant,
  });

  @override
  State<PomegranateChatPanel> createState() => _PomegranateChatPanelState();
}

class _PomegranateChatPanelState extends State<PomegranateChatPanel> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  ChatLang? selectedLang;
  bool sending = false;

  final List<ChatMessage> messages = [];

  // Pomegranate color scheme
  static const pomegranateRed = Color(0xFFC73E1D);
  static const pomegranateDeep = Color(0xFF8B2635);
  static const pomegranatePink = Color(0xFFE8959C);
  static const pomegranateLight = Color(0xFFFFF5F5);
  static const pomegranateSeed = Color(0xFFB8434D);

  static const langs = <ChatLang>[
    ChatLang("en", "English", "Pomegranate Chat"),
    ChatLang("si", "සිංහල", "දෙළුම් Chat"),
    ChatLang("sg", "Singlish", "Delum Chat"),
  ];

  List<Map<String, dynamic>> _buildGeminiHistory() {
    final out = <Map<String, dynamic>>[];
    for (final m in messages) {
      if (m.role == ChatRole.user) {
        out.add({"role": "user", "parts": [{"text": m.text}]});
      } else if (m.role == ChatRole.model) {
        out.add({"role": "model", "parts": [{"text": m.text}]});
      }
    }
    return out;
  }

  String _welcome(String lang) {
    if (lang == "si") {
      return "ඔබට දෙළුම් පිළිබඳ ප්‍රශ්න අසන්න පුළුවන්. (මෙම රූපයේ ප්‍රතිඵල මත පදනම්ව පිළිතුරු දේ.)";
    }
    if (lang == "sg") {
      return "Delum related prashna ahanna puluwan. (Me image results walata adala widiyata reply denawa.)";
    }
    return "You can ask pomegranate questions. (I answer using this image's results.)";
  }

  Future<void> _ensureLangSelected() async {
    if (selectedLang != null) return;

    final picked = await showModalBottomSheet<ChatLang>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: pomegranateLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: pomegranatePink,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: pomegranateRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.language,
                          color: pomegranateRed,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Select Chat Language",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: pomegranateDeep,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final l in langs)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: pomegranateRed.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [pomegranateRed, pomegranateSeed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        l.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: pomegranateDeep,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: pomegranatePink),
                      onTap: () => Navigator.pop(ctx, l),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );

    if (picked == null) return;

    setState(() {
      selectedLang = picked;
      messages.clear();
      messages.add(ChatMessage(role: ChatRole.model, text: _welcome(picked.code)));
    });
  }

  void _resetChat() {
    setState(() {
      selectedLang = null;
      messages.clear();
      _controller.clear();
    });
  }

  Future<void> _send() async {
    await _ensureLangSelected();
    if (selectedLang == null) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      sending = true;
      messages.add(ChatMessage(role: ChatRole.user, text: text));
      _controller.clear();
    });

    try {
      final reply = await widget.assistant.answer(
        userQuestion: text,
        pipelineResult: widget.pipelineResult,
        uiLang: selectedLang!.code,
        historyContents: _buildGeminiHistory(),
      );

      setState(() {
        messages.add(ChatMessage(role: ChatRole.model, text: reply));
        sending = false;
      });
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(role: ChatRole.model, text: "Error: $e"));
        sending = false;
      });
    }

    await Future.delayed(const Duration(milliseconds: 50));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.pipelineResult.stage == PipelineStage.closeFreshnessDone;
    final title = selectedLang?.title ?? "Select Language to Chat";

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            pomegranateLight,
            Colors.white,
            pomegranateLight,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: pomegranateRed.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: pomegranatePink.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pomegranateRed, pomegranateSeed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton.icon(
                    onPressed: sending ? null : _ensureLangSelected,
                    icon: const Icon(Icons.language, color: Colors.white, size: 20),
                    label: Text(
                      selectedLang?.label ?? "Choose",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    tooltip: "Reset chat",
                    onPressed: sending
                        ? null
                        : () async {
                      _resetChat();
                      await _ensureLangSelected();
                    },
                    icon: const Icon(Icons.restart_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!enabled)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedLang?.code == "si"
                                ? "Chat ලබාගැනීමට පෙර ✅ දෙළුම් + ✅ ලඟ + ✅ freshness ප්‍රතිඵල ලැබිය යුතුයි."
                                : (selectedLang?.code == "sg")
                                ? "Chat unlock wenne ✅ delum + ✅ close + ✅ freshness result awama witharai."
                                : "Chat unlocks only after ✅ pomegranate + ✅ close + ✅ freshness result.",
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Messages container
                Container(
                  height: 380,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: pomegranatePink.withOpacity(0.2)),
                  ),
                  child: messages.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [pomegranateRed.withOpacity(0.1), pomegranatePink.withOpacity(0.1)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: pomegranateRed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Start a conversation",
                          style: TextStyle(
                            color: pomegranateDeep.withOpacity(0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final isUser = m.role == ChatRole.user;

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            gradient: isUser
                                ? LinearGradient(
                              colors: [pomegranateRed, pomegranateSeed],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : null,
                            color: isUser ? null : pomegranateLight,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                            ),
                            border: Border.all(
                              color: isUser ? Colors.transparent : pomegranatePink.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isUser ? pomegranateRed : pomegranatePink).withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            m.text,
                            style: TextStyle(
                              color: isUser ? Colors.white : pomegranateDeep,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Input row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: enabled ? pomegranateRed.withOpacity(0.3) : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: enabled
                              ? [
                            BoxShadow(
                              color: pomegranateRed.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                              : null,
                        ),
                        child: TextField(
                          controller: _controller,
                          enabled: enabled && !sending,
                          style: const TextStyle(color: pomegranateDeep),
                          decoration: InputDecoration(
                            hintText: selectedLang?.code == "si"
                                ? "දෙළුම් ගැන අහන්න..."
                                : (selectedLang?.code == "sg")
                                ? "Delum gana ahanna..."
                                : "Ask about this pomegranate...",
                            hintStyle: TextStyle(color: pomegranateDeep.withOpacity(0.4)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: (enabled && !sending)
                            ? LinearGradient(
                          colors: [pomegranateRed, pomegranateSeed],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: (!enabled || sending) ? Colors.grey.shade300 : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: (enabled && !sending)
                            ? [
                          BoxShadow(
                            color: pomegranateRed.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                            : null,
                      ),
                      child: IconButton(
                        onPressed: (enabled && !sending) ? _send : null,
                        icon: sending
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}