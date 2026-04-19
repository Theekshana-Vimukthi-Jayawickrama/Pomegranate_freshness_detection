import tensorflow as tf
import os
models = [
    'assets/models/pomegranate_present_fp16.tflite',
    'assets/models/pomegranate_detector_float16.tflite',
    'assets/models/modelB/model_fp16.tflite',
    'assets/models/student_prod_fp16.tflite',
]
for model in models:
    path = os.path.abspath(model)
    print('---', model)
    try:
        interpreter = tf.lite.Interpreter(model_path=path)
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        for i, inp in enumerate(input_details):
            print(f'in[{i}] shape={inp["shape"]} dtype={inp["dtype"]} quant={inp.get("quantization",None)}')
        for i, out in enumerate(output_details):
            print(f'out[{i}] shape={out["shape"]} dtype={out["dtype"]} quant={out.get("quantization",None)}')
    except Exception as e:
        print('ERROR', e)
    print()
