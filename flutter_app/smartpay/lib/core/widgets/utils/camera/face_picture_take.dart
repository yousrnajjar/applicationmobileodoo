// Lib:
// Widget qui permet de prendre une photo avec la caméra de la face de l'utilisateur et de le retourné
// à la page précédente

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:smartpay/core/widgets/utils/camera/take_picture.dart';

const double radius = 100.0;
const boxSize = Size(200.0, 200.0);

enum CameraType { front, back }

enum CameraState { start, stop, pause }

class FacePictureTakeWidget extends TakePictureWidget {
  @override
  double? get cHeight => boxSize.height;
  @override
  double? get cWidth => boxSize.width;
  @override
  CameraLensDirection? get cameraLensDirection => CameraLensDirection.front;
  const FacePictureTakeWidget({
    super.key,
    super.onPictureTaken
  });
}
