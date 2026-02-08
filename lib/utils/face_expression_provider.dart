import 'package:fer_detection_app/services/face_expression_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final faceExpressionProvider = Provider<FaceExpressionService>((ref) {
  return FaceExpressionService();
});
