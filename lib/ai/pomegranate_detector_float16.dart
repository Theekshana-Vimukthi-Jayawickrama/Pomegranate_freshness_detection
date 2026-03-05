import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PomDetectResult {
  final double score; // best confidence
  final bool isPomegranate;

  PomDetectResult({required this.score, required this.isPomegranate});

  @override
  String toString() => "PomDetectResult(score=$score, isPomegranate=$isPomegranate)";
}

class PomegranateDetectorFloat16 {
  final String assetPath;
  final double threshold;

  Interpreter? _interpreter;
  List<int>? _inShape;   // [1,H,W,3]
  List<int>? _outShape;  // [1,5,8400]

  PomegranateDetectorFloat16({
    required this.assetPath,
    required this.threshold,
  });

  bool get isLoaded => _interpreter != null;

  Future<void> load({int threads = 2}) async {
    if (_interpreter != null) return;

    final opts = InterpreterOptions()..threads = threads;
    _interpreter = await Interpreter.fromAsset(assetPath, options: opts);

    final inTensor = _interpreter!.getInputTensor(0);
    _inShape = inTensor.shape;

    final outTensor = _interpreter!.getOutputTensor(0);
    _outShape = outTensor.shape;

    // ignore: avoid_print
    print("✅ Detector loaded: $assetPath");
    // ignore: avoid_print
    print("Input : shape=${inTensor.shape} type=${inTensor.type}");
    // ignore: avoid_print
    print("Output: shape=${outTensor.shape} type=${outTensor.type}");
    // ignore: avoid_print
    print("Threshold: $threshold");
  }

  /// ✅ SAFE: auto-load if needed
  Future<PomDetectResult> predict(Uint8List imageBytes, {bool debug = false}) async {
    if (_interpreter == null || _inShape == null || _outShape == null) {
      await load();
    }

    final inShape = _inShape!;
    final outShape = _outShape!;

    final h = inShape[1];
    final w = inShape[2];

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) throw Exception("Invalid image bytes");

    final resized = img.copyResize(decoded, width: w, height: h);

    // Input float32 [1,h,w,3] normalized 0..1
    final input = Float32List(1 * h * w * 3);
    int idx = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = resized.getPixel(x, y);
        input[idx++] = p.r / 255.0;
        input[idx++] = p.g / 255.0;
        input[idx++] = p.b / 255.0;
      }
    }

    // Handle several possible output shapes produced by different TFLite builds.
    double bestConf = 0.0;

    if (outShape.length == 3) {
      final outB = outShape[0];
      final d1 = outShape[1];
      final d2 = outShape[2];

      if (d1 == 5) {
        // shape [1,5,N] -> access output[0][4][i]
        final output = List.generate(
          outB,
          (_) => List.generate(
            d1,
            (_) => List.filled(d2, 0.0),
          ),
        );
        _interpreter!.run(input.reshapeTo4D(1, h, w, 3), output);
        for (int i = 0; i < d2; i++) {
          final conf = (output[0][4][i] as num).toDouble();
          if (conf > bestConf) bestConf = conf;
        }
      } else if (d2 == 5) {
        // shape [1,N,5] -> access output[0][i][4]
        final output = List.generate(
          outB,
          (_) => List.generate(
            d1,
            (_) => List.filled(d2, 0.0),
          ),
        );
        _interpreter!.run(input.reshapeTo4D(1, h, w, 3), output);
        for (int i = 0; i < d1; i++) {
          final conf = (output[0][i][4] as num).toDouble();
          if (conf > bestConf) bestConf = conf;
        }
      } else {
        // Unexpected 3D layout: flatten and try to find confidence at stride-5 positions
        final total = d1 * d2;
        final flat = List.filled(total, 0.0);
        _interpreter!.run(input.reshapeTo4D(1, h, w, 3), flat);
        // assume groups of 5 (x,y,w,h,conf)
        final n = total ~/ 5;
        for (int i = 0; i < n; i++) {
          final conf = (flat[i * 5 + 4] as num).toDouble();
          if (conf > bestConf) bestConf = conf;
        }
      }
    } else if (outShape.length == 2) {
      // Handle classifier-style output [1,1] or flat detections [1,M]
      final dim1 = outShape[1];
      if (dim1 == 1) {
        // Classifier: single score
        final output = List.generate(1, (_) => List.filled(1, 0.0));
        _interpreter!.run(input.reshapeTo4D(1, h, w, 3), output);
        final raw = output[0][0];
        bestConf = (raw is double) ? raw : (raw as num).toDouble();
      } else {
        // 2D flat detections [1, M] — try interpreting as flat detections (groups of 5)
        final total = dim1;
        final flat = List.filled(total, 0.0);
        _interpreter!.run(input.reshapeTo4D(1, h, w, 3), flat);
        final n = total ~/ 5;
        for (int i = 0; i < n; i++) {
          final conf = (flat[i * 5 + 4] as num).toDouble();
          if (conf > bestConf) bestConf = conf;
        }
      }
    } else {
      throw Exception("Unsupported detector output shape: $outShape");
    }

    final isPom = bestConf >= threshold;

    if (debug) {
      // ignore: avoid_print
      print("=== Detector DEBUG ===");
      // ignore: avoid_print
      print("bestConf=$bestConf thr=$threshold => isPomegranate=$isPom");
      // ignore: avoid_print
      print("outShape=$outShape");
    }

    return PomDetectResult(score: bestConf, isPomegranate: isPom);
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _inShape = null;
    _outShape = null;
  }
}

extension _ReshapeFloat32List on Float32List {
  List<List<List<List<double>>>> reshapeTo4D(int b, int h, int w, int c) {
    int idx = 0;
    return List.generate(b, (_) {
      return List.generate(h, (_) {
        return List.generate(w, (_) {
          return List.generate(c, (_) => this[idx++]);
        });
      });
    });
  }
}
