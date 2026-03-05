// import 'dart:typed_data';

// import 'pomegranate_detector_float16.dart';
// import 'model_a_verifier_224.dart';
// import 'model_b_distance_predictor.dart';
// import 'freshness_only_predictor.dart';

// enum PipelineStage {
//   notPomegranate,
//   far,
//   closeFreshnessDone,
//   error,
// }

// class PipelineResult {
//   final PipelineStage stage;
//   final String message;

//   final PomDetectResult? d; // detector
//   final ModelAResult? a;    // ✅ must exist for your assistant + XAI
//   final ModelBResult? b;
//   final FreshnessOnlyResult? f;

//   PipelineResult({
//     required this.stage,
//     required this.message,
//     this.d,
//     this.a,
//     this.b,
//     this.f,
//   });
// }

// class PomegranatePipeline {
//   // Model 0: YOLO detector
//   final PomegranateDetectorFloat16 detector = PomegranateDetectorFloat16(
//     assetPath: "assets/models/pomegranate_present_fp16.tflite",
//     threshold: 0.50,
//   );

//   // Model A: ✅ your new pomegranate presence model
//   final ModelAVerifier224 modelA = ModelAVerifier224();

//   // Model B: distance
//   final ModelBDistancePredictor modelB = ModelBDistancePredictor();

//   // Freshness
//   final FreshnessOnlyPredictor freshness = FreshnessOnlyPredictor();

//   bool _loaded = false;
//   bool get isLoaded => _loaded;

//   Future<void> load() async {
//     if (_loaded) return;

//     // Load models one-by-one with explicit error context so we can tell
//     // which model fails or hangs. This helps debugging when the UI stays
//     // on "Loading models...".
//     try {
//       try {
//         // Detector
//         // ignore: avoid_print
//         print('PomegranatePipeline: loading detector...');
//         await detector.load(threads: 2);
//       } catch (e, st) {
//         // ignore: avoid_print
//         print('PomegranatePipeline: detector.load failed: $e\n$st');
//         // ensure interpreter closed if partially created
//         try {
//           detector.close();
//         } catch (_) {}
//         rethrow;
//       }

//       // try {
//       //   // Model A
//       //   // ignore: avoid_print
//       //   print('PomegranatePipeline: loading modelA...');
//       //   await modelA.load(threads: 2);
//       // } catch (e, st) {
//       //   // ignore: avoid_print
//       //   print('PomegranatePipeline: modelA.load failed: $e\n$st');
//       //   try {
//       //     modelA.close();
//       //   } catch (_) {}
//       //   rethrow;
//       // }

//       try {
//         // Model B
//         // ignore: avoid_print
//         print('PomegranatePipeline: loading modelB...');
//         await modelB.load();
//       } catch (e, st) {
//         // ignore: avoid_print
//         print('PomegranatePipeline: modelB.load failed: $e\n$st');
//         try {
//           modelB.close();
//         } catch (_) {}
//         rethrow;
//       }

//       try {
//         // Freshness
//         // ignore: avoid_print
//         print('PomegranatePipeline: loading freshness...');
//         await freshness.load(threads: 4);
//       } catch (e, st) {
//         // ignore: avoid_print
//         print('PomegranatePipeline: freshness.load failed: $e\n$st');
//         try {
//           freshness.close();
//         } catch (_) {}
//         rethrow;
//       }

//       _loaded = true;
//       // ignore: avoid_print
//       print('PomegranatePipeline: all models loaded');
//     } catch (e, st) {
//       // Final cleanup
//       try {
//         detector.close();
//       } catch (_) {}
//       try {
//         modelA.close();
//       } catch (_) {}
//       try {
//         modelB.close();
//       } catch (_) {}
//       try {
//         freshness.close();
//       } catch (_) {}

//       throw Exception('PomegranatePipeline.load failed: $e');
//     }
//   }

//   Future<PipelineResult> run(Uint8List imageBytes) async {
//     try {
//       await load();

//       // 0) Detector
//       final d = await detector.predict(imageBytes, debug: true);
//       if (!d.isPomegranate) {
//         return PipelineResult(
//           stage: PipelineStage.notPomegranate,
//           message:
//               "❌ Not OK: No pomegranate detected. (Detector conf=${d.score.toStringAsFixed(3)})",
//           d: d,
//         );
//       }

//       // 1) Model A (pomegranate present verifier)
//       // final a = modelA.predict(imageBytes, debug: true);
//       // if (!a.isPomegranate) {
//       //   return PipelineResult(
//       //     stage: PipelineStage.notPomegranate,
//       //     message:
//       //         "❌ Not OK: Not a pomegranate. (ModelA score=${a.score.toStringAsFixed(3)} thr=${a.threshold.toStringAsFixed(2)})",
//       //     d: d,
//       //     a: a,
//       //   );
//       // }

//       // 2) Model B (distance)
//       final b = await modelB.predict(imageBytes);
//       if (!b.isClose) {
//         return PipelineResult(
//           stage: PipelineStage.far,
//           message: "❌ Not OK: Pomegranate detected but image is too FAR.",
//           d: d,
          
//           b: b,
//         );
//       }

//       // 3) Freshness
//       final f = await freshness.predict(imageBytes);

//       return PipelineResult(
//         stage: PipelineStage.closeFreshnessDone,
//         message:
//             "✅ OK: ${f.label.toUpperCase()} (conf ${(f.confidence * 100).toStringAsFixed(1)}%)",
//         d: d,
        
//         b: b,
//         f: f,
//       );
//     } catch (e) {
//       return PipelineResult(
//         stage: PipelineStage.error,
//         message: "❌ Error: $e",
//       );
//     }
//   }

//   void close() {
//     detector.close();
//     modelA.close();
//     modelB.close();
//     freshness.close();
//     _loaded = false;
//   }
// }

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
