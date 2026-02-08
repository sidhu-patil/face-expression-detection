import 'dart:typed_data';

import 'package:fer_detection_app/features/report/viewmodels/color_type.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';

class FaceResultCard extends StatelessWidget {
  final Map<String, Object> item;
  const FaceResultCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final croppedImage = item["image"] as img.Image;
    final expressions = item['expression'] as Map<String, double>;

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
                                        getColorForExpression(e.key),
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
}
