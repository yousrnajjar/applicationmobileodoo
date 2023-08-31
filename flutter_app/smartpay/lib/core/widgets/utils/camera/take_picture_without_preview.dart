import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Take picture without preview or camera screen or anything in front
Future<XFile> takePictureWithoutPreview() async {
  final cameras = await availableCameras();
  final frontCamera = cameras.firstWhere(
    (element) => element.lensDirection == CameraLensDirection.front,
    orElse: () => cameras.first,
  );
  final CameraController cameraController = CameraController(
    frontCamera,
    ResolutionPreset.medium,
  );
  await cameraController.initialize();
  final XFile file = await cameraController.takePicture();
  return file;
}
