import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    show Face;

class ReportState {
  final bool isLoading;
  final String? error;
  final List<Face> faces;
  final List<Map<String, Object>> data;

  ReportState({
    this.isLoading = false,
    this.error,
    this.faces = const [],
    this.data = const [],
  });

  ReportState copyWith({
    bool? isLoading,
    String? error,
    List<Face>? faces,
    List<Map<String, Object>>? data,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      faces: faces ?? this.faces,
      data: data ?? this.data,
    );
  }
}

class ResolutionInfo {
  final double width;
  final double height;
  ResolutionInfo(this.width, this.height);
}
