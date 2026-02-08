import 'package:flutter/material.dart';

Color getColorForExpression(String expression) {
  switch (expression.toLowerCase()) {
    case 'happy':
      return Colors.green;
    case 'sad':
      return Colors.blueGrey;
    case 'angry':
      return Colors.red;
    case 'surprise':
      return Colors.orange;
    case 'neutral':
      return Colors.blue;
    default:
      return Colors.purple;
  }
}
