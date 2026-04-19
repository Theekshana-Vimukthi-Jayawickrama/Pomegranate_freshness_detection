// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';

// class ModelBResult {
//   final double prob;        // model output probability
//   final bool isClose;       // prob >= threshold
//   final String label;       // "close" or "far"
//   final double threshold;

//   /// compatibility with other results that use `confidence`
//   double get confidence => prob;

//   ModelBResult({
//     required this.prob,
//     required this.isClose,
//     required this.label,
//     required this.threshold,
//   });

//   @override
//   String toString() =>
//       'ModelBResult(prob=$prob, threshold=$threshold, isClose=$isClose, label=$label)';
// }

// class ModelBDistancePredictor {
//   // ====== Asset paths (as you said) ======
//   static const String _modelPath = 'assets/models/modelB/model_fp16.tflite';
//   static const String _thresholdPath = 'assets/models/modelB/threshold.json';
//   static const String _labelsPath = 'assets/models/modelB/labels.json';

//   // ====== Expected input size (match your Colab) ======
//   static const int imgSize = 224;

//   Interpreter? _interpreter;
//   double _threshold = 0.5;

//   // Store labels by int key (0,1)
//   Map<int, String> _labels = {0: 'far', 1: 'close'};

//   bool get isLoaded => _interpreter != null;
//   double get threshold => _threshold;
//   Map<int, String> get labels => _labels;

//   Future<void> load() async {
//     // 1) Load interpreter from asset
//     final options = InterpreterOptions()
//       ..threads = 2; // you can change
//     _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

//     // 2) Load threshold.json
//     final thStr = await rootBundle.loadString(_thresholdPath);
//     final thJson = jsonDecode(thStr);
//     final thVal = thJson['threshold'];
//     _threshold = (thVal is int) ? thVal.toDouble() : (thVal as num).toDouble();

//     // 3) Load labels.json
//     final lbStr = await rootBundle.loadString(_labelsPath);
//     final lbJson = jsonDecode(lbStr);

//     // Accept both {"0":"far","1":"close"} or {0:"far",1:"close"} styles
//     final Map<int, String> parsed = {};
//     lbJson.forEach((k, v) {
//       final keyInt = int.tryParse(k.toString());
//       if (keyInt != null) parsed[keyInt] = v.toString();
//     });
//     if (parsed.isNotEmpty) _labels = parsed;

//     // Debug prints (same vibe as your logs)
//     final input = _interpreter!.getInputTensor(0);
//     final output = _interpreter!.getOutputTensor(0);
//     // ignore: avoid_print
//     print('✅ Model B loaded');
//     // ignore: avoid_print
//     print('Input shape: ${input.shape} type: ${input.type}');
//     // ignore: avoid_print
//     print('Output shape: ${output.shape} type: ${output.type}');
//     // ignore: avoid_print
//     print('Threshold: $_threshold');
//     // ignore: avoid_print
//     print('Labels: $_labels');
//   }

//   void close() {
//     _interpreter?.close();
//     _interpreter = null;
//   }

//   /// Main API: pass raw image bytes (from gallery/camera/file)
//   Future<ModelBResult> predict(Uint8List imageBytes) async {
//     if (_interpreter == null) {
//       throw StateError('ModelB not loaded. Call load() first.');
//     }

//     // 1) Decode image
//     final decoded = img.decodeImage(imageBytes);
//     if (decoded == null) {
//       throw Exception('Invalid image bytes (decode failed)');
//     }

//     // 2) Force RGB + resize/crop like ImageOps.fit in Colab
//     //    -> center crop to square then resize to 224x224
//     final square = _centerCropToSquare(decoded);
//     final resized = img.copyResize(square, width: imgSize, height: imgSize);

//     // 3) Convert to float32 input [1,224,224,3] in [0,1]
//     final input = _imageToFloat32Input(resized);

//     // 4) Output buffer [1,1]
//     final output = List.generate(1, (_) => List.filled(1, 0.0));

//     // 5) Run inference
//     _interpreter!.run(input, output);

//     final prob = (output[0][0] as double);
//     final isClose = prob >= _threshold;
//     final label = isClose ? (_labels[1] ?? 'close') : (_labels[0] ?? 'far');

//     return ModelBResult(
//       prob: prob,
//       isClose: isClose,
//       label: label,
//       threshold: _threshold,
//     );
//   }

//   // ===== Helpers =====

//   img.Image _centerCropToSquare(img.Image src) {
//     final w = src.width;
//     final h = src.height;
//     final size = w < h ? w : h;
//     final x = (w - size) ~/ 2;
//     final y = (h - size) ~/ 2;
//     return img.copyCrop(src, x: x, y: y, width: size, height: size);
//   }

//   /// Returns a nested List shaped [1][224][224][3] with float values
//   List<List<List<List<double>>>> _imageToFloat32Input(img.Image im) {
//     final input = List.generate(
//       1,
//           (_) => List.generate(
//         imgSize,
//             (_) => List.generate(
//           imgSize,
//               (_) => List.filled(3, 0.0),
//         ),
//       ),
//     );

//     for (int y = 0; y < imgSize; y++) {
//       for (int x = 0; x < imgSize; x++) {
//         final p = im.getPixel(x, y);
//         final r = p.r / 255.0;
//         final g = p.g / 255.0;
//         final b = p.b / 255.0;
//         input[0][y][x][0] = r;
//         input[0][y][x][1] = g;
//         input[0][y][x][2] = b;
//       }
//     }
//     return input;
//   }
// }

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelBResult {
  final double prob;        // model output probability
  final bool isClose;       // prob >= threshold
  final String label;       // "close" or "far"
  final double threshold;

  /// compatibility with other results that use `confidence`
  double get confidence => prob;

  ModelBResult({
    required this.prob,
    required this.isClose,
    required this.label,
    required this.threshold,
  });

  @override
  String toString() =>
      'ModelBResult(prob=$prob, threshold=$threshold, isClose=$isClose, label=$label)';
}

class ModelBDistancePredictor {
  // ====== Asset paths (as you said) ======
  static const String _modelPath = 'assets/models/modelB/model_fp16.tflite';
  static const String _thresholdPath = 'assets/models/modelB/threshold.json';
  static const String _labelsPath = 'assets/models/modelB/labels.json';

  // ====== Expected input size (match your Colab) ======
  static const int imgSize = 224;

  Interpreter? _interpreter;
  double _threshold = 0.5;

  // Store labels by int key (0,1)
  Map<int, String> _labels = {0: 'far', 1: 'close'};

  bool get isLoaded => _interpreter != null;
  double get threshold => _threshold;
  Map<int, String> get labels => _labels;

  Future<void> load() async {
    // 1) Load interpreter from asset
    final options = InterpreterOptions()
      ..threads = 2; // you can change
    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

    // 2) Load threshold.json
    final thStr = await rootBundle.loadString(_thresholdPath);
    final thJson = jsonDecode(thStr);
    final thVal = thJson['threshold'];
    _threshold = (thVal is int) ? thVal.toDouble() : (thVal as num).toDouble();

    // 3) Load labels.json
    final lbStr = await rootBundle.loadString(_labelsPath);
    final lbJson = jsonDecode(lbStr);

    // Accept both {"0":"far","1":"close"} or {0:"far",1:"close"} styles
    final Map<int, String> parsed = {};
    lbJson.forEach((k, v) {
      final keyInt = int.tryParse(k.toString());
      if (keyInt != null) parsed[keyInt] = v.toString();
    });
    if (parsed.isNotEmpty) _labels = parsed;

    // Debug prints (same vibe as your logs)
    final input = _interpreter!.getInputTensor(0);
    final output = _interpreter!.getOutputTensor(0);
    // ignore: avoid_print
    print('✅ Model B loaded');
    // ignore: avoid_print
    print('Input shape: ${input.shape} type: ${input.type}');
    // ignore: avoid_print
    print('Output shape: ${output.shape} type: ${output.type}');
    // ignore: avoid_print
    print('Threshold: $_threshold');
    // ignore: avoid_print
    print('Labels: $_labels');
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }

  /// Main API: pass raw image bytes (from gallery/camera/file)
  Future<ModelBResult> predict(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw StateError('ModelB not loaded. Call load() first.');
    }

    // 1) Decode image
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception('Invalid image bytes (decode failed)');
    }

    // 2) Force RGB + resize/crop like ImageOps.fit in Colab
    //    -> center crop to square then resize to 224x224
    final square = _centerCropToSquare(decoded);
    final resized = img.copyResize(square, width: imgSize, height: imgSize);

    // 3) Convert to float32 input [1,224,224,3] in [0,1]
    final input = _imageToFloat32Input(resized);

    // 4) Output buffer [1,1]
    final output = List.generate(1, (_) => List.filled(1, 0.0));

    // 5) Run inference
    _interpreter!.run(input, output);

    final prob = (output[0][0] as double);
    final isClose = prob >= _threshold;
    final label = isClose ? (_labels[1] ?? 'close') : (_labels[0] ?? 'far');

    return ModelBResult(
      prob: prob,
      isClose: isClose,
      label: label,
      threshold: _threshold,
    );
  }

  // ===== Helpers =====

  img.Image _centerCropToSquare(img.Image src) {
    final w = src.width;
    final h = src.height;
    final size = w < h ? w : h;
    final x = (w - size) ~/ 2;
    final y = (h - size) ~/ 2;
    return img.copyCrop(src, x: x, y: y, width: size, height: size);
  }

  /// Returns a nested List shaped [1][224][224][3] with float values
  List<List<List<List<double>>>> _imageToFloat32Input(img.Image im) {
    final input = List.generate(
      1,
          (_) => List.generate(
        imgSize,
            (_) => List.generate(
          imgSize,
              (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < imgSize; y++) {
      for (int x = 0; x < imgSize; x++) {
        final p = im.getPixel(x, y);
        final r = p.r / 255.0;
        final g = p.g / 255.0;
        final b = p.b / 255.0;
        input[0][y][x][0] = r;
        input[0][y][x][1] = g;
        input[0][y][x][2] = b;
      }
    }
    return input;
  }
}