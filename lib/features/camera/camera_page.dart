import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

import './viewmodels/camera_provider.dart';

@RoutePage()
class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraAsync = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);

    return cameraAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicatorM3E())),
      error: (_, _) =>
          const Scaffold(body: Center(child: Text("Camera error"))),
      data: (controller) {
        if (controller == null) {
          return const Scaffold(body: Center(child: Text("No camera found")));
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: ClipRRect(
                  child: SizedOverflowBox(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.width,
                    ),
                    child: CameraPreview(controller),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.router.back(),
                    ),
                    IconButton(
                      icon: Icon(
                        notifier.flashMode == FlashMode.off
                            ? Icons.flash_off
                            : notifier.flashMode == FlashMode.auto
                            ? Icons.flash_auto
                            : Icons.flash_on,
                        color: Colors.white,
                      ),
                      onPressed: notifier.toggleFlash,
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_android,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: notifier.switchCamera,
                    ),

                    GestureDetector(
                      onTap: notifier.onCapturePressed,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                    ),

                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
