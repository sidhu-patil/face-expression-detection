import 'package:auto_route/auto_route.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:fer_detection_app/features/report/models/report_model.dart';
import 'package:fer_detection_app/features/report/viewmodels/report_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

@RoutePage()
class ReportPage extends ConsumerStatefulWidget {
  final String imagePath;
  const ReportPage({super.key, required this.imagePath});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportViewModelProvider.notifier).processImage(widget.imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Analysis Report",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicatorM3E())
          : state.error != null
          ? Center(
              child: Text(
                "Error: ${state.error}",
                style: GoogleFonts.inter(color: Colors.deepOrange),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  _buildHeaderSection(state.faces.length),
                  const SizedBox(height: 20),

                  // Image with Bounding Boxes
                  Center(child: _buildImageWithBoundingBoxes(state)),
                  const SizedBox(height: 30),

                  // Result Cards
                  Text(
                    "Detailed Analysis",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...state.data.map(
                    (item) => _buildFaceResultCard(context, item),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection(int faceCount) {
    return Column(
      children: [
        Text(
          "$faceCount Faces Detected",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "AI-Powered Expression Analysis",
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildImageWithBoundingBoxes(ReportState state) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FutureBuilder<ResolutionInfo?>(
              future: _getImageResolution(widget.imagePath),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Image.file(File(widget.imagePath));
                }

                return CustomPaint(
                  foregroundPainter: FacePainter(
                    faces: state.faces,
                    imageResolution: snapshot.data!,
                  ),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<ResolutionInfo?> _getImageResolution(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);
    return ResolutionInfo(image.width.toDouble(), image.height.toDouble());
  }

  Widget _buildFaceResultCard(BuildContext context, Map<String, Object> item) {
    final croppedImage = item["image"] as img.Image;
    final expressions = item['expression'] as Map<String, double>;

    // Convert sorted entries to list
    final sortedEntries = expressions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final dominantExpression = sortedEntries.first;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Face Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                image: DecorationImage(
                  image: MemoryImage(
                    Uint8List.fromList(img.encodePng(croppedImage)),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dominantExpression.key.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${(dominantExpression.value * 100).toStringAsFixed(1)}%",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  ...sortedEntries
                      .skip(1)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: GoogleFonts.inter(
                                  color: Colors.grey[700],
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: LinearProgressIndicator(
                                      value: e.value,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getColorForExpression(e.key),
                                      ),
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${(e.value * 100).toStringAsFixed(0)}%",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForExpression(String expression) {
    // Return colors based on emotion sentiment
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
}

class ResolutionInfo {
  final double width;
  final double height;
  ResolutionInfo(this.width, this.height);
}

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final ResolutionInfo imageResolution;

  FacePainter({required this.faces, required this.imageResolution});

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imageResolution.width;
    final double scaleY = size.height / imageResolution.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.deepOrange;

    for (var face in faces) {
      final rect = Rect.fromLTRB(
        face.boundingBox.left * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.right * scaleX,
        face.boundingBox.bottom * scaleY,
      );

      // Draw Bounding Box
      // canvas.drawRect(rect, paint);

      // Draw Cornerstone Box (Corners only for better aesthetics)
      _drawCornerRect(canvas, rect, paint);
    }
  }

  void _drawCornerRect(Canvas canvas, Rect rect, Paint paint) {
    double cornerLength = 20.0;

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
