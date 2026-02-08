import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceExpressionService {
  static final FaceExpressionService _instance =
      FaceExpressionService._internal();

  factory FaceExpressionService() {
    return _instance;
  }

  FaceExpressionService._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model.tflite',
        options: InterpreterOptions(),
      );

      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n');
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  Future<Map<String, double>> predict(img.Image faceImage) async {
    if (_interpreter == null) {
      await loadModel();
      if (_interpreter == null) {
        return {"Error": 0.0};
      }
    }

    img.Image resized = img.copyResize(faceImage, width: 48, height: 48);
    img.Image grayscale = img.grayscale(resized);
    var input = List.generate(
      1,
      (i) => List.generate(
        48,
        (j) => List.generate(48, (k) => List.generate(1, (l) => 0.0)),
      ),
    );

    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        final pixel = grayscale.getPixel(x, y);
        double val = pixel.r / 255.0;
        input[0][y][x][0] = val;
      }
    }

    var output = List.filled(1, List.filled(_labels.length, 0.0).toList());

    _interpreter!.run(input, output);

    Map<String, double> results = {};
    for (int i = 0; i < _labels.length; i++) {
      String label = _labels[i].trim();
      if (label.isNotEmpty) {
        results[label] = output[0][i];
      }
    }

    return results;
  }

  void dispose() {
    _interpreter?.close();
  }
}
