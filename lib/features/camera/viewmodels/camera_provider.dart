import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fer_detection_app/router/app_router.dart';
import 'package:fer_detection_app/router/app_router.gr.dart';
import 'package:fer_detection_app/utils/cameras_provider.dart';

class CameraProvider extends AsyncNotifier<CameraController?> {
  int _cameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;

  @override
  Future<CameraController?> build() async {
    final cameras = ref.read(camerasProvider);
    if (cameras.isEmpty) return null;

    final controller = CameraController(
      cameras[_cameraIndex],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    await controller.setFlashMode(_flashMode);

    ref.onDispose(() {
      controller.dispose();
    });

    return controller;
  }

  Future<void> onCapturePressed() async {
    final controller = state.value;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();
      if (!ref.mounted) return;

      ref.read(appRouterProvider).push(ReportRoute(imagePath: file.path));
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  Future<void> switchCamera() async {
    final cameras = ref.read(camerasProvider);
    if (cameras.length < 2) return;

    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> toggleFlash() async {
    final controller = state.value;
    if (controller == null) return;

    _flashMode = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.off,
      _ => FlashMode.off,
    };

    await controller.setFlashMode(_flashMode);
    state = AsyncData(controller);
  }

  FlashMode get flashMode => _flashMode;
}

final cameraProvider = AsyncNotifierProvider<CameraProvider, CameraController?>(
  CameraProvider.new,
);
