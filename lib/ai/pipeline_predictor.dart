

import 'dart:typed_data';

import 'pomegranate_detector_float16.dart';
import 'model_a_verifier_224.dart';
import 'model_b_distance_predictor.dart';
import 'freshness_only_predictor.dart';

enum PipelineStage {
  notPomegranate,
  far,
  closeFreshnessDone,
  error,
}

class PipelineResult {
  final PipelineStage stage;
  final String message;

  final PomDetectResult? d; 
  final ModelAResult? a;            // optional output from model A verifier
  final ModelBResult? b;
  final FreshnessOnlyResult? f;

  PipelineResult({
    required this.stage,
    required this.message,
    this.d,
    this.a,
    this.b,
    this.f,
  });
}

class PomegranatePipeline {
  // Model 0: YOLO detector
  final PomegranateDetectorFloat16 detector =
      PomegranateDetectorFloat16(
    assetPath: "assets/models/pomegranate_present_fp16.tflite",
    threshold: 0.50,
  );

  // Model B: distance
  final ModelBDistancePredictor modelB =
      ModelBDistancePredictor();

  // Freshness model
  final FreshnessOnlyPredictor freshness =
      FreshnessOnlyPredictor();

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    try {
      print("Loading detector...");
      await detector.load(threads: 2);

      print("Loading Model B...");
      await modelB.load();

      print("Loading Freshness model...");
      await freshness.load(threads: 4);

      _loaded = true;
      print("All models loaded successfully.");
    } catch (e) {
      close();
      throw Exception("Pipeline load failed: $e");
    }
  }

  Future<PipelineResult> run(Uint8List imageBytes) async {
    try {
      await load();

      // -------------------------
      // Stage 0: Detector
      // -------------------------
      final d = await detector.predict(imageBytes);

      if (!d.isPomegranate) {
        return PipelineResult(
          stage: PipelineStage.notPomegranate,
          message:
              "No pomegranate detected (confidence ${(d.score * 100).toStringAsFixed(1)}%)",
          d: d,
        );
      }

      // -------------------------
      // Stage 1: Distance (Model B)
      // -------------------------
      final b = await modelB.predict(imageBytes);

      if (!b.isClose) {
        return PipelineResult(
          stage: PipelineStage.far,
          message:
              "Pomegranate detected but image too far (confidence ${(b.confidence * 100).toStringAsFixed(1)}%)",
          d: d,
          b: b,
        );
      }

      // -------------------------
      // Stage 2: Freshness
      // -------------------------
      final f = await freshness.predict(imageBytes);

      return PipelineResult(
        stage: PipelineStage.closeFreshnessDone,
        message:
            "Freshness: ${f.label.toUpperCase()} "
            "(confidence ${(f.confidence * 100).toStringAsFixed(1)}%)",
        d: d,
        b: b,
        f: f,
      );
    } catch (e) {
      return PipelineResult(
        stage: PipelineStage.error,
        message: "Pipeline error: $e",
      );
    }
  }

  void close() {
    detector.close();
    modelB.close();
    freshness.close();
    _loaded = false;
  }
}