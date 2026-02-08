import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fer_detection_app/features/home/viewmodels/home_viewmodels.dart';
import 'package:fer_detection_app/features/home/views/action_button.dart';
import 'package:fer_detection_app/router/app_router.gr.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FER App",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: .bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: .start,
                children: const [
                  Icon(
                    Icons.face_retouching_natural,
                    size: 42,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Face Expression Recognition",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Detect emotions from human faces in real-time",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Choose input method",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    icon: Icons.camera_alt_rounded,
                    title: "Camera",
                    subtitle: "Real-time detection",
                    onTap: () {
                      context.router.pushPath('/camera');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ActionCard(
                    icon: Icons.photo_library_rounded,
                    title: "Gallery",
                    subtitle: "Analyze saved image",
                    onTap: () async {
                      final pickedFile = await ref
                          .read(imagesProvider)
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null && context.mounted) {
                        context.router.push(
                          ReportRoute(imagePath: pickedFile.path),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
