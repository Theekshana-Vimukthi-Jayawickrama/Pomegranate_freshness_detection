// import 'dart:typed_data';
// import 'dart:math';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;

// class FreshnessOnlyResult {
//   final double freshProb;
//   final double nonFreshProb;

//   FreshnessOnlyResult({
//     required this.freshProb,
//     required this.nonFreshProb,
//   });

//   String get label => (freshProb >= nonFreshProb) ? "fresh" : "non_fresh";
//   double get confidence => max(freshProb, nonFreshProb);
// }

// class FreshnessOnlyPredictor {
//   Interpreter? _interpreter;
//   bool _loading = false;

//   // Change if your model output order is different.
//   // Your student model usually has freshness output shape [1,2] at index 2.
//   final int freshnessOutputIndex = 2;

//   Future<void> load({int threads = 4}) async {
//     if (_interpreter != null || _loading) return;
//     _loading = true;

//     final opts = InterpreterOptions()..threads = threads;

//     _interpreter = await Interpreter.fromAsset(
//       'assets/models/student_prod_fp16.tflite',
//       options: opts,
//     );

//     _loading = false;
//   }

//   /// Center-crop square -> resize 224 -> normalize 0..1
//   List<List<List<List<double>>>> _preprocess(Uint8List bytes) {
//     final decoded = img.decodeImage(bytes);
//     if (decoded == null) throw Exception("Invalid image");

//     final oriented = img.bakeOrientation(decoded);

//     // center crop square
//     final w = oriented.width;
//     final h = oriented.height;
//     final side = min(w, h);
//     final left = ((w - side) / 2).round();
//     final top = ((h - side) / 2).round();

//     final cropped = img.copyCrop(oriented, x: left, y: top, width: side, height: side);
//     final resized = img.copyResize(
//       cropped,
//       width: 224,
//       height: 224,
//       interpolation: img.Interpolation.cubic,
//     );

//     return [
//       List.generate(224, (y) {
//         return List.generate(224, (x) {
//           final p = resized.getPixel(x, y);
//           return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
//         });
//       })
//     ];
//   }

//   Future<FreshnessOnlyResult> predict(Uint8List imageBytes) async {
//     await load();

//     final input = _preprocess(imageBytes);

//     // student model outputs (example):
//     final out0 = List.generate(1, (_) => List.filled(1, 0.0)); // present
//     final out1 = List.generate(1, (_) => List.filled(1, 0.0)); // quality
//     final out2 = List.generate(1, (_) => List.filled(2, 0.0)); // freshness [fresh, non_fresh]

//     final outputs = <int, Object>{0: out0, 1: out1, 2: out2};

//     _interpreter!.runForMultipleInputs([input], outputs);

//     // pick freshness output
//     List<List<double>> freshOut;
//     if (freshnessOutputIndex == 0) {
//       throw Exception("freshnessOutputIndex=0 is invalid for your current containers");
//     } else if (freshnessOutputIndex == 1) {
//       throw Exception("freshnessOutputIndex=1 is invalid for your current containers");
//     } else {
//       freshOut = out2;
//     }

//     final freshProb = (freshOut[0][0] as num).toDouble();
//     final nonFreshProb = (freshOut[0][1] as num).toDouble();

//     return FreshnessOnlyResult(freshProb: freshProb, nonFreshProb: nonFreshProb);
//   }

//   void close() {
//     _interpreter?.close();
//     _interpreter = null;
//   }
// }

import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FreshnessOnlyResult {
  final double freshProb;
  final double nonFreshProb;

  FreshnessOnlyResult({
    required this.freshProb,
    required this.nonFreshProb,
  });

  String get label => (freshProb >= nonFreshProb) ? "fresh" : "non_fresh";
  double get confidence => max(freshProb, nonFreshProb);
}

class FreshnessOnlyPredictor {
  Interpreter? _interpreter;
  bool _loading = false;

  /// We will auto-detect which output is freshness ([1,2]).
  int? _freshnessOutIndex;

  Future<void> load({int threads = 4}) async {
    if (_interpreter != null || _loading) return;
    _loading = true;

    final opts = InterpreterOptions()..threads = threads;

    _interpreter = await Interpreter.fromAsset(
      'assets/models/student_prod_fp16.tflite',
      options: opts,
    );

    // Auto-detect freshness output index:
    _freshnessOutIndex = _findFreshnessOutputIndex();

    // Debug prints (keep ON for now)
    final inT = _interpreter!.getInputTensor(0);
    // ignore: avoid_print
    print("✅ Freshness model loaded");
    // ignore: avoid_print
    print("Input0: shape=${inT.shape} type=${inT.type}");
    for (int i = 0; i < _interpreter!.getOutputTensors().length; i++) {
      final t = _interpreter!.getOutputTensor(i);
      // ignore: avoid_print
      print("Out$i: shape=${t.shape} type=${t.type}");
    }
    // ignore: avoid_print
    print("Freshness output index = $_freshnessOutIndex");

    _loading = false;
  }

  int _findFreshnessOutputIndex() {
    final outs = _interpreter!.getOutputTensors();
    // Look for tensor with shape [1,2]
    for (int i = 0; i < outs.length; i++) {
      final s = outs[i].shape;
      if (s.length == 2 && s[0] == 1 && s[1] == 2) return i;
      // Sometimes it could be [2] too (rare)
      if (s.length == 1 && s[0] == 2) return i;
    }
    // If not found, fallback to last output (but do NOT crash)
    return max(0, outs.length - 1);
  }

  /// Center-crop square -> resize 224 -> normalize 0..1
  List<List<List<List<double>>>> _preprocess(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception("Invalid image");

    final oriented = img.bakeOrientation(decoded);

    final w = oriented.width;
    final h = oriented.height;
    final side = min(w, h);
    final left = ((w - side) / 2).round();
    final top = ((h - side) / 2).round();

    final cropped = img.copyCrop(oriented, x: left, y: top, width: side, height: side);
    final resized = img.copyResize(
      cropped,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.cubic,
    );

    return [
      List.generate(224, (y) {
        return List.generate(224, (x) {
          final p = resized.getPixel(x, y);
          return [
            p.r / 255.0,
            p.g / 255.0,
            p.b / 255.0,
          ];
        });
      })
    ];
  }

  /// Create output container matching tensor shape
  Object _makeOutputContainer(List<int> shape) {
    // Common shapes:
    // [1,1] -> List<List<double>>
    // [1,2] -> List<List<double>>
    // [2]   -> List<double>
    if (shape.length == 2) {
      return List.generate(shape[0], (_) => List.filled(shape[1], 0.0));
    }
    if (shape.length == 1) {
      return List.filled(shape[0], 0.0);
    }
    // Generic fallback
    int total = 1;
    for (final d in shape) total *= d;
    return List.filled(total, 0.0);
  }

  Future<FreshnessOnlyResult> predict(Uint8List imageBytes) async {
    await load();

    final input = _preprocess(imageBytes);

    final outTensors = _interpreter!.getOutputTensors();
    final outputs = <int, Object>{};

    // Build correct containers ONLY for available outputs
    for (int i = 0; i < outTensors.length; i++) {
      outputs[i] = _makeOutputContainer(outTensors[i].shape);
    }

    _interpreter!.runForMultipleInputs([input], outputs);

    final idx = _freshnessOutIndex ?? _findFreshnessOutputIndex();
    final out = outputs[idx];

    double freshProb;
    double nonFreshProb;

    // Handle [1,2]
    if (out is List<List<double>> && out.isNotEmpty && out[0].length >= 2) {
      freshProb = (out[0][0] as num).toDouble();
      nonFreshProb = (out[0][1] as num).toDouble();
    }
    // Handle [2]
    else if (out is List<double> && out.length >= 2) {
      freshProb = (out[0] as num).toDouble();
      nonFreshProb = (out[1] as num).toDouble();
    } else {
      throw Exception("Freshness output shape not supported. Output=$out");
    }

    return FreshnessOnlyResult(freshProb: freshProb, nonFreshProb: nonFreshProb);
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _freshnessOutIndex = null;
  }
}
