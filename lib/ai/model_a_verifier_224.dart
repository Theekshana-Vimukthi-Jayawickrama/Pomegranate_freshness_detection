import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelAResult {
  final double score; // sigmoid 0..1
  final bool isPomegranate;
  final String label;
  final double threshold;
  final double confidence; // max(score, 1-score)

  ModelAResult({
    required this.score,
    required this.isPomegranate,
    required this.label,
    required this.threshold,
    required this.confidence,
  });
}

class ModelAVerifier224 {
  static const String _modelPath = 'assets/models/modelA/model_fp16.tflite';
  static const String _thrPath = 'assets/models/modelA/threshold.json';
  static const String _labelsPath = 'assets/models/modelA/labels.json';

  late final Interpreter _interpreter;
  late final double threshold;
  late final Map<String, dynamic> labels;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Call once (e.g., initState)
  Future<void> load({int threads = 2}) async {
    final thrStr = await rootBundle.loadString(_thrPath);
    final thrJson = json.decode(thrStr) as Map<String, dynamic>;
    threshold = (thrJson['threshold'] as num?)?.toDouble() ?? 0.5;

    final labStr = await rootBundle.loadString(_labelsPath);
    labels = json.decode(labStr) as Map<String, dynamic>;

    final options = InterpreterOptions()..threads = threads;
    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);

    final inT = _interpreter.getInputTensors().first;
    final outT = _interpreter.getOutputTensors().first;

    // debug prints
    // ignore: avoid_print
    print("✅ Model A loaded");
    // ignore: avoid_print
    print("Input shape=${inT.shape} type=${inT.type}");
    // ignore: avoid_print
    print("Output shape=${outT.shape} type=${outT.type}");
    // ignore: avoid_print
    print("Threshold=$threshold labels=$labels");

    _loaded = true;
  }

  /// Synchronous predict (main thread). Use predictAsync for better UX.
  ModelAResult predict(Uint8List imageBytes, {bool debug = true}) {
    if (!_loaded) throw StateError("ModelAVerifier224.load() not called");
    final input = _preprocessImageBytes(imageBytes);
    if (debug) _printStats(input);
    return _runInference(input);
  }

  /// Async predict: preprocess in isolate, infer on main thread.
  /// Better UX—UI stays responsive during heavy image decoding/cropping.
  Future<ModelAResult> predictAsync(Uint8List imageBytes, {bool debug = true}) async {
    if (!_loaded) throw StateError("ModelAVerifier224.load() not called");
    final input = await compute(_preprocessImageBytesIsolate, imageBytes);
    if (debug) _printStats(input);
    return _runInference(input);
  }

  /// Run inference on the preprocessed input.
  ModelAResult _runInference(List<List<List<List<double>>>> input) {
    final output = List.generate(1, (_) => List.filled(1, 0.0));
    _interpreter.run(input, output);

    final score = (output[0][0] as num).toDouble();
    final isPom = score >= threshold;
    final labelKey = isPom ? "1" : "0";
    final label = (labels[labelKey] ?? (isPom ? "pomegranate" : "not_pomegranate")).toString();
    final conf = max(score, 1.0 - score);

    return ModelAResult(
      score: score,
      isPomegranate: isPom,
      label: label,
      threshold: threshold,
      confidence: conf,
    );
  }

  /// Preprocess raw image bytes. Safe to run in isolate.
  List<List<List<List<double>>>> _preprocessImageBytes(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) throw ArgumentError("Invalid image bytes");

    // Fix EXIF rotation
    final oriented = img.bakeOrientation(decoded);

    // Force RGB (flatten alpha onto white)
    final rgb = _ensureRgb(oriented);

    // PIL ImageOps.fit equivalent: center crop square then resize
    final fitted = _fitCenterCrop(rgb, 224);

    // Build Float32 input [1,224,224,3] in range [-1,+1]
    return _toMobileNetV2Input(fitted);
  }

  void close() {
    if (_loaded) {
      _interpreter.close();
      _loaded = false;
    }
  }

  // ----------------------------
  // Helpers (match Colab)
  // ----------------------------

  img.Image _fitCenterCrop(img.Image src, int size) {
    final w = src.width;
    final h = src.height;

    final side = min(w, h);
    final left = ((w - side) / 2).round();
    final top = ((h - side) / 2).round();

    final cropped = img.copyCrop(src, x: left, y: top, width: side, height: side);

    return img.copyResize(
      cropped,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
  }

  img.Image _ensureRgb(img.Image src) {
    final out = img.Image(width: src.width, height: src.height);

    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);

        final a = p.a / 255.0;
        final r = (p.r * a + 255.0 * (1 - a)).round();
        final g = (p.g * a + 255.0 * (1 - a)).round();
        final b = (p.b * a + 255.0 * (1 - a)).round();

        out.setPixelRgb(x, y, r, g, b);
      }
    }
    return out;
  }

  // MobileNetV2 preprocess_input: (x/127.5)-1.0
  List<List<List<List<double>>>> _toMobileNetV2Input(img.Image im) {
    const int size = 224;

    final input = List.generate(
      1,
          (_) => List.generate(
        size,
            (_) => List.generate(size, (_) => List.filled(3, 0.0)),
      ),
    );

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final p = im.getPixel(x, y);

        input[0][y][x][0] = (p.r / 127.5) - 1.0;
        input[0][y][x][1] = (p.g / 127.5) - 1.0;
        input[0][y][x][2] = (p.b / 127.5) - 1.0;
      }
    }
    return input;
  }

  void _printStats(List<List<List<List<double>>>> input) {
    double mn = double.infinity, mx = -double.infinity, sum = 0.0;
    int n = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        for (int c = 0; c < 3; c++) {
          final v = input[0][y][x][c];
          mn = min(mn, v);
          mx = max(mx, v);
          sum += v;
          n++;
        }
      }
    }

    // ignore: avoid_print
    print("INPUT stats (expected ~[-1,+1]) min=$mn max=$mx mean=${sum / n}");
  }
}

/// Top-level function for isolate-safe preprocessing. Used with compute().
List<List<List<List<double>>>> _preprocessImageBytesIsolate(Uint8List imageBytes) {
  final decoded = img.decodeImage(imageBytes);
  if (decoded == null) throw ArgumentError("Invalid image bytes");

  // Fix EXIF rotation
  final oriented = img.bakeOrientation(decoded);

  // Force RGB (flatten alpha onto white)
  final rgb = _ensureRgbIsolate(oriented);

  // PIL ImageOps.fit equivalent: center crop square then resize
  final fitted = _fitCenterCropIsolate(rgb, 224);

  // Build Float32 input [1,224,224,3] in range [-1,+1]
  return _toMobileNetV2InputIsolate(fitted);
}

img.Image _ensureRgbIsolate(img.Image src) {
  final out = img.Image(width: src.width, height: src.height);

  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);

      final a = p.a / 255.0;
      final r = (p.r * a + 255.0 * (1 - a)).round();
      final g = (p.g * a + 255.0 * (1 - a)).round();
      final b = (p.b * a + 255.0 * (1 - a)).round();

      out.setPixelRgb(x, y, r, g, b);
    }
  }
  return out;
}

img.Image _fitCenterCropIsolate(img.Image src, int size) {
  final w = src.width;
  final h = src.height;

  final side = (w < h ? w : h);
  final left = ((w - side) / 2).round();
  final top = ((h - side) / 2).round();

  final cropped = img.copyCrop(src, x: left, y: top, width: side, height: side);

  return img.copyResize(
    cropped,
    width: size,
    height: size,
    interpolation: img.Interpolation.cubic,
  );
}

List<List<List<List<double>>>> _toMobileNetV2InputIsolate(img.Image im) {
  const int size = 224;

  final input = List.generate(
    1,
    (_) => List.generate(
      size,
      (_) => List.generate(size, (_) => List.filled(3, 0.0)),
    ),
  );

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final p = im.getPixel(x, y);

      input[0][y][x][0] = (p.r / 127.5) - 1.0;
      input[0][y][x][1] = (p.g / 127.5) - 1.0;
      input[0][y][x][2] = (p.b / 127.5) - 1.0;
    }
  }
  return input;
}
