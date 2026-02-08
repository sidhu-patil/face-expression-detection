import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:fer_detection_app/features/report/models/report_model.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final ResolutionInfo imageResolution;

  FacePainter({required this.faces, required this.imageResolution});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageResolution.width == 0 || imageResolution.height == 0) return;

    final fittedSizes = applyBoxFit(
      BoxFit.contain,
      Size(imageResolution.width, imageResolution.height),
      size,
    );
    final destinationRect = Alignment.center.inscribe(
      fittedSizes.destination,
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    final double scaleX = destinationRect.width / imageResolution.width;
    final double scaleY = destinationRect.height / imageResolution.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (var face in faces) {
      final rect = Rect.fromLTRB(
        face.boundingBox.left * scaleX + destinationRect.left,
        face.boundingBox.top * scaleY + destinationRect.top,
        face.boundingBox.right * scaleX + destinationRect.left,
        face.boundingBox.bottom * scaleY + destinationRect.top,
      );
      _drawCornerRect(canvas, rect, paint);
    }
  }

  void _drawCornerRect(Canvas canvas, Rect rect, Paint paint) {
    double cornerLength = 8.0;

    // Top Left
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(0, cornerLength),
      paint,
    );

    // Top Right
    canvas.drawLine(
      rect.topRight,
      rect.topRight - Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(0, cornerLength),
      paint,
    );

    // Bottom Left
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft - Offset(0, cornerLength),
      paint,
    );

    // Bottom Right
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight - Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight - Offset(0, cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.faces != faces ||
        oldDelegate.imageResolution != imageResolution;
  }
}
