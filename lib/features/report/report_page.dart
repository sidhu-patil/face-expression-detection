import 'package:auto_route/auto_route.dart';
import 'package:image/image.dart' as img;
import 'package:fer_detection_app/features/report/views/face_result_card.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

import 'package:fer_detection_app/features/report/models/report_model.dart';
import 'package:fer_detection_app/features/report/viewmodels/report_viewmodel.dart';
import 'package:fer_detection_app/features/report/views/bouding_box.dart';

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
                  Column(
                    children: [
                      Text(
                        "${state.faces.length} Faces Detected",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "AI-Powered Expression Analysis",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
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
                  ),
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
                  ...state.data.map((item) => FaceResultCard(item: item)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Future<ResolutionInfo?> _getImageResolution(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return null;

    final orientedImage = img.bakeOrientation(image);

    return ResolutionInfo(
      orientedImage.width.toDouble(),
      orientedImage.height.toDouble(),
    );
  }
}
