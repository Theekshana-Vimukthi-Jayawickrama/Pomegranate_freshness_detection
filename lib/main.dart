import 'package:flutter/material.dart';
import 'package:pomegrnate_freshness_detection/pages/gemini_chat_test_page.dart';
import 'package:pomegrnate_freshness_detection/pages/gemini_connection_test_page.dart';
import 'package:pomegrnate_freshness_detection/pages/pipeline_test_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
        home: const PipelineTestPage(),
    );
  }
}
