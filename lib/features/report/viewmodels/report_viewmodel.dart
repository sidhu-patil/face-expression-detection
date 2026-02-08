import 'dart:io';
import 'package:fer_detection_app/features/report/models/report_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'package:fer_detection_app/services/face_expression_service.dart';
import 'package:fer_detection_app/utils/face_expression_provider.dart';

class ReportViewModel extends Notifier<ReportState> {
  late final FaceExpressionService _expressionService;

  @override
  ReportState build() {
    _expressionService = ref.read(faceExpressionProvider);
    return ReportState();
  }

  Future<void> processImage(String imagePath) async {
    state = state.copyWith(isLoading: true, data: [], error: null);

    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableTracking: true,
          minFaceSize: 0.1,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: "No face detected in the image.",
        );

        faceDetector.close();
        return;
      }

      state = state.copyWith(faces: faces);

      for (var face in faces) {
        final fileFn = File(imagePath);
        final bytes = await fileFn.readAsBytes();
        final originalImage = img.decodeImage(bytes);

        if (originalImage != null) {
          final x = face.boundingBox.left.toInt();
          final y = face.boundingBox.top.toInt();
          final w = face.boundingBox.width.toInt();
          final h = face.boundingBox.height.toInt();

          final safeX = x < 0 ? 0 : x;
          final safeY = y < 0 ? 0 : y;
          final safeW = (safeX + w) > originalImage.width
              ? (originalImage.width - safeX)
              : w;
          final safeH = (safeY + h) > originalImage.height
              ? (originalImage.height - safeY)
              : h;

          final cropped = img.copyCrop(
            originalImage,
            x: safeX,
            y: safeY,
            width: safeW,
            height: safeH,
          );

          final expressions = await _expressionService.predict(cropped);

          state = state.copyWith(
            data: [
              ...state.data,
              {"image": cropped, "expression": expressions},
            ],
          );
        } else {
          debugPrint("Original image is null");
        }
      }

      faceDetector.close();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reportViewModelProvider = NotifierProvider<ReportViewModel, ReportState>(
  ReportViewModel.new,
);
