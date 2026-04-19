import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() async {
  final models = [
    'assets/models/pomegranate_present_fp16.tflite',
    'assets/models/pomegranate_detector_float16.tflite',
    'assets/models/modelB/model_fp16.tflite',
    'assets/models/student_prod_fp16.tflite',
  ];
  for (final model in models) {
    try {
      print('--- $model ---');
      final interpreter = await Interpreter.fromFile(File(model));
      final inputs = interpreter.getInputTensors();
      final outputs = interpreter.getOutputTensors();
      for (var i = 0; i < inputs.length; i++) {
        final t = inputs[i];
        print('in[$i] shape=${t.shape} type=${t.type}');
      }
      for (var i = 0; i < outputs.length; i++) {
        final t = outputs[i];
        print('out[$i] shape=${t.shape} type=${t.type}');
      }
      interpreter.close();
    } catch (e, st) {
      print('ERROR $model: $e');
      print(st);
    }
    print('');
  }
}
