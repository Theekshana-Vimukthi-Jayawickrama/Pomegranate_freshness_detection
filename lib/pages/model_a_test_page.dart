import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../ai/model_a_verifier_224.dart';

class ModelATestPage extends StatefulWidget {
  const ModelATestPage({super.key});

  @override
  State<ModelATestPage> createState() => _ModelATestPageState();
}

class _ModelATestPageState extends State<ModelATestPage> {
  final picker = ImagePicker();
  final verifier = ModelAVerifier224();

  bool loading = true;
  String status = "Loading Model A...";
  Uint8List? bytes;
  ModelAResult? result;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await verifier.load(threads: 2);
    setState(() {
      loading = false;
      status = "✅ Ready";
    });
  }

  Future<void> _pick(ImageSource source) async {
    final x = await picker.pickImage(source: source, imageQuality: 100);
    if (x == null) return;

    final b = await x.readAsBytes();

    setState(() {
      bytes = b;
      result = null;
      status = "Running inference...";
      loading = true;
    });

    // allow UI to update and show the loading indicator
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final r = await verifier.predictAsync(b, debug: true);
      setState(() {
        result = r;
        status = r.isPomegranate ? "✅ POMEGRANATE" : "❌ NOT POMEGRANATE";
      });
    } catch (e) {
      setState(() {
        status = "❌ Inference error: $e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    verifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = result;

    return Scaffold(
      appBar: AppBar(title: const Text("Model A Verifier (224)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (loading)
              Column(
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Running Model A...",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (bytes != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(bytes!, fit: BoxFit.contain),
                ),
              ),

            if (r != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Label: ${r.label}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("Score: ${r.score.toStringAsFixed(4)}"),
                    Text("Threshold: ${r.threshold.toStringAsFixed(4)}"),
                    Text("Decision: ${r.isPomegranate ? "POMEGRANATE ✅" : "NOT POMEGRANATE ❌"}"),
                    Text("Confidence: ${(r.confidence * 100).toStringAsFixed(1)}%"),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
