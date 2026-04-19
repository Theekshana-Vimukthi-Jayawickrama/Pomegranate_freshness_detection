// import 'dart:typed_data';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';

// class PomPresentResult {
//   final double prob; // 0..1
//   final double threshold;

//   PomPresentResult({required this.prob, required this.threshold});

//   bool get isPomegranate => prob >= threshold;
// }

// class PomegranatePresent224 {
//   final String assetPath;
//   final int inputSize;
//   final double threshold;

//   Interpreter? _interpreter;

//   bool get isLoaded => _interpreter != null;

//   PomegranatePresent224({
//     required this.assetPath,
//     this.inputSize = 224,
//     this.threshold = 0.50,
//   });

//   Future<void> load({int threads = 2}) async {
//     if (_interpreter != null) return;

//     final options = InterpreterOptions()..threads = threads;
//     _interpreter = await Interpreter.fromAsset(assetPath, options: options);
//   }

//   PomPresentResult predict(Uint8List imageBytes, {bool debug = false}) {
//     final itp = _interpreter;
//     if (itp == null) {
//       throw StateError("PomegranatePresent224 not loaded. Call load() first.");
//     }

//     // Decode image
//     final decoded = img.decodeImage(imageBytes);
//     if (decoded == null) {
//       throw ArgumentError("Cannot decode image bytes.");
//     }

//     // Resize to 224x224
//     final resized = img.copyResize(
//       decoded,
//       width: inputSize,
//       height: inputSize,
//       interpolation: img.Interpolation.linear,
//     );

//     // Input tensor: [1,224,224,3] float32, normalized 0..1
//     final input = Float32List(inputSize * inputSize * 3);
//     int i = 0;
//     for (int y = 0; y < inputSize; y++) {
//       for (int x = 0; x < inputSize; x++) {
//         final p = resized.getPixel(x, y);
//         input[i++] = p.r / 255.0;
//         input[i++] = p.g / 255.0;
//         input[i++] = p.b / 255.0;
//       }
//     }

//     // Convert to nested list for tflite_flutter
//     final inputTensor = _reshapeTo4D(input, inputSize);

//     // Output usually [1,1] sigmoid
//     final output = List.generate(1, (_) => List.filled(1, 0.0));

//     itp.run(inputTensor, output);

//     final raw = output[0][0];
//     final prob = (raw is double) ? raw : (raw as num).toDouble();
//     final clipped = prob.isNaN ? 0.0 : prob.clamp(0.0, 1.0);

//     if (debug) {
//       // ignore: avoid_print
//       print("PomegranatePresent224 prob=${clipped.toStringAsFixed(4)} thr=$threshold");
//     }

//     return PomPresentResult(prob: clipped, threshold: threshold);
//   }

//   void close() {
//     _interpreter?.close();
//     _interpreter = null;
//   }

//   // Helper: Float32List -> [1,H,W,3]
//   List<List<List<List<double>>>> _reshapeTo4D(Float32List data, int size) {
//     int idx = 0;
//     return [
//       List.generate(size, (_) {
//         return List.generate(size, (_) {
//           return [
//             data[idx++].toDouble(),
//             data[idx++].toDouble(),
//             data[idx++].toDouble(),
//           ];
//         });
//       }),
//     ];
//   }
// }

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PomPresentResult {
  final double prob; // 0..1
  final double threshold;

  PomPresentResult({required this.prob, required this.threshold});

  bool get isPomegranate => prob >= threshold;
}

class PomegranatePresent224 {
  final String assetPath;
  final int inputSize;
  final double threshold;

  Interpreter? _interpreter;

  bool get isLoaded => _interpreter != null;

  PomegranatePresent224({
    required this.assetPath,
    this.inputSize = 224,
    this.threshold = 0.50,
  });

  Future<void> load({int threads = 2}) async {
    if (_interpreter != null) return;

    final options = InterpreterOptions()..threads = threads;
    _interpreter = await Interpreter.fromAsset(assetPath, options: options);
  }

  PomPresentResult predict(Uint8List imageBytes, {bool debug = false}) {
    final itp = _interpreter;
    if (itp == null) {
      throw StateError("PomegranatePresent224 not loaded. Call load() first.");
    }

    // Decode image
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw ArgumentError("Cannot decode image bytes.");
    }

    // Resize to 224x224
    final resized = img.copyResize(
      decoded,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Input tensor: [1,224,224,3] float32, normalized 0..1
    final input = Float32List(inputSize * inputSize * 3);
    int i = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final p = resized.getPixel(x, y);
        input[i++] = p.r / 255.0;
        input[i++] = p.g / 255.0;
        input[i++] = p.b / 255.0;
      }
    }

    // Convert to nested list for tflite_flutter
    final inputTensor = _reshapeTo4D(input, inputSize);

    // Output usually [1,1] sigmoid
    final output = List.generate(1, (_) => List.filled(1, 0.0));

    itp.run(inputTensor, output);

    final raw = output[0][0];
    final prob = (raw is double) ? raw : (raw as num).toDouble();
    final clipped = prob.isNaN ? 0.0 : prob.clamp(0.0, 1.0);

    if (debug) {
      // ignore: avoid_print
      print("PomegranatePresent224 prob=${clipped.toStringAsFixed(4)} thr=$threshold");
    }

    return PomPresentResult(prob: clipped, threshold: threshold);
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }

  // Helper: Float32List -> [1,H,W,3]
  List<List<List<List<double>>>> _reshapeTo4D(Float32List data, int size) {
    int idx = 0;
    return [
      List.generate(size, (_) {
        return List.generate(size, (_) {
          return [
            data[idx++].toDouble(),
            data[idx++].toDouble(),
            data[idx++].toDouble(),
          ];
        });
      }),
    ];
  }
}