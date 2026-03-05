import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../ai/model_b_distance_predictor.dart';

class ModelBTestPage extends StatefulWidget {
  const ModelBTestPage({super.key});

  @override
  State<ModelBTestPage> createState() => _ModelBTestPageState();
}

class _ModelBTestPageState extends State<ModelBTestPage> {
  final picker = ImagePicker();
  final predictor = ModelBDistancePredictor();

  Uint8List? imageBytes;
  String status = "Loading Model B...";
  ModelBResult? result;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await predictor.load();
      setState(() {
        status = "✅ Model B loaded. Pick an image.";
        loading = false;
      });
    } catch (e) {
      setState(() {
        status = "❌ Failed to load model: $e";
        loading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();

    setState(() {
      imageBytes = bytes;
      result = null;
      status = "Running inference...";
      loading = true;
    });

    try {
      final r = await predictor.predict(bytes);
      setState(() {
        result = r;
        status = "✅ Done";
        loading = false;
      });
    } catch (e) {
      setState(() {
        status = "❌ Inference error: $e";
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    predictor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Model B Distance Test (Close/Far)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(status),
            const SizedBox(height: 12),

            if (imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(imageBytes!, height: 220, fit: BoxFit.cover),
              ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: loading ? null : pickImage,
              child: const Text("Pick Image"),
            ),

            const SizedBox(height: 16),

            if (loading)
              Column(
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Processing image...",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
  
              if (result != null)
                Column(
                  children: [
                    Text(
                      "Prediction: ${result!.label.toUpperCase()}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("prob = ${result!.prob.toStringAsFixed(4)}"),
                    Text("threshold = ${result!.threshold.toStringAsFixed(4)}"),
                    Text("isClose = ${result!.isClose}"),
                  ],
                ),
            ],
        ),
      ),
    );
  }
}
