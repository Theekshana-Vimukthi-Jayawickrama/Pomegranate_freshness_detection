import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Result from the 3‑class pomegranate classifier.
class PomegranateCloseFarResult {
  final int predictedClass;   // 0: not_pomegranate, 1: close, 2: far
  final double confidence;    // softmax probability of the predicted class
  final bool isClose;         // true if predictedClass == 1
  final bool isPomegranate;   // true if predictedClass == 1 or 2
  final String label;         // "not_pomegranate", "close", "far"

  PomegranateCloseFarResult({
    required this.predictedClass,
    required this.confidence,
    required this.isClose,
    required this.isPomegranate,
    required this.label,
  });

  @override
  String toString() =>
      'PomegranateCloseFarResult(class=$predictedClass, label=$label, confidence=$confidence, isClose=$isClose)';
}

/// Classifier that uses the 3‑class pomegranate model (not_pomegranate / close / far).
class PomegranateCloseFarClassifier {
  static const String _modelPath = 'assets/models/pomegranate_model.tflite';
  static const int _imgSize = 224;        // model input size

  Interpreter? _interpreter;
  bool get isLoaded => _interpreter != null;

  /// Load the TFLite model from assets.
  Future<void> load({int threads = 2}) async {
    if (_interpreter != null) return;

    final options = InterpreterOptions()..threads = threads;
    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

    // Debug: print input/output details
    final inputTensor = _interpreter!.getInputTensor(0);
    final outputTensor = _interpreter!.getOutputTensor(0);
    print('✅ PomegranateCloseFarClassifier loaded');
    print('   Input shape : ${inputTensor.shape} (expected [1,224,224,3])');
    print('   Output shape: ${outputTensor.shape} (expected [1,3])');
  }

  /// Release resources.
  void close() {
    _interpreter?.close();
    _interpreter = null;
  }

  /// Run inference on raw image bytes.
  /// Returns a [PomegranateCloseFarResult] with the prediction.
  Future<PomegranateCloseFarResult> predict(Uint8List imageBytes) async {
    if (_interpreter == null) {
      throw StateError('Classifier not loaded. Call load() first.');
    }

    // 1) Decode image
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception('Invalid image bytes – could not decode');
    }

    // 2) Preprocess: center crop to square, resize to 224x224, normalize to [0,1]
    final square = _centerCropToSquare(decoded);
    final resized = img.copyResize(square, width: _imgSize, height: _imgSize);
    final input = _imageToFloat32Input(resized); // shape [1,224,224,3]

    // 3) Output buffer: [1,3] for softmax probabilities
    final output = List.generate(1, (_) => List.filled(3, 0.0));

    // 4) Run inference
    _interpreter!.run(input, output);

    // 5) Parse result
    final probabilities = output[0] as List<double>;
    final predictedClass = _argmax(probabilities);
    final confidence = probabilities[predictedClass];

    // Map class index to label and boolean flags
    String label;
    bool isClose;
    bool isPomegranate;

    switch (predictedClass) {
      case 0:
        label = 'not_pomegranate';
        isClose = false;
        isPomegranate = false;
        break;
      case 1:
        label = 'close';
        isClose = true;
        isPomegranate = true;
        break;
      case 2:
        label = 'far';
        isClose = false;
        isPomegranate = true;
        break;
      default:
        throw Exception('Unexpected class index: $predictedClass');
    }

    return PomegranateCloseFarResult(
      predictedClass: predictedClass,
      confidence: confidence,
      isClose: isClose,
      isPomegranate: isPomegranate,
      label: label,
    );
  }

  // ---------- Helper methods (identical to your ModelB implementation) ----------
  img.Image _centerCropToSquare(img.Image src) {
    final w = src.width;
    final h = src.height;
    final size = w < h ? w : h;
    final x = (w - size) ~/ 2;
    final y = (h - size) ~/ 2;
    return img.copyCrop(src, x: x, y: y, width: size, height: size);
  }

  /// Returns a nested List shaped [1][224][224][3] with float values in [0,1].
  List<List<List<List<double>>>> _imageToFloat32Input(img.Image im) {
    final input = List.generate(
      1,
      (_) => List.generate(
        _imgSize,
        (_) => List.generate(
          _imgSize,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < _imgSize; y++) {
      for (int x = 0; x < _imgSize; x++) {
        final p = im.getPixel(x, y);
        input[0][y][x][0] = p.r / 255.0;
        input[0][y][x][1] = p.g / 255.0;
        input[0][y][x][2] = p.b / 255.0;
      }
    }
    return input;
  }

  int _argmax(List<double> list) {
    int maxIdx = 0;
    double maxVal = list[0];
    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxVal) {
        maxVal = list[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }
}