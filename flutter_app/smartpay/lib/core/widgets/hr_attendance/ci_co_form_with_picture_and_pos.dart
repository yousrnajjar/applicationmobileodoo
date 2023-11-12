import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartpay/core/widgets/utils/geolocator.dart';

import 'check_in_check_out_form.dart';

// Base size
class CheckInCheckOutFormWithPicture extends CheckInCheckOutForm {
  const CheckInCheckOutFormWithPicture({
    super.key,
    required super.employee,
  });

  @override
  State<CheckInCheckOutForm> createState() =>
      _CheckInCheckOutFormWithPictureState();
}

class _CheckInCheckOutFormWithPictureState extends CheckInCheckOutFormState {
  @override
  Future<Map<String, dynamic>?> checkIn() async {
    final Uint8List bytes = await takePicture();
    Position position = await getPosition();
    var att = await super.checkIn();
    await attendance.addImageAndPosition(bytes, position);
    return att;
  }

  Future<Position> getPosition() async {
    var enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      showInSnackBar("Le service de localisation est désactivé.");
      return Future.error('Location services are disabled.');
    }
    return await PositionGetter.position;
  }

  @override
  Future<Map<String, dynamic>?> checkOut() async {
    final Uint8List bytes = await takePicture();
    Position position = await getPosition();
    var att = await super.checkOut();
    await attendance.addImageAndPosition(bytes, position, isCheckOut: true);
    return att;
  }

  Future<Uint8List> takePicture() async {
    XFile imageFile = await takePictureWithoutPreview(context);
    final path = imageFile.path;
    final Uint8List bytes = await File(path).readAsBytes();
    return bytes;
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  /// Take picture without preview or camera screen or anything in front
  Future<XFile> takePictureWithoutPreview(BuildContext context) async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (element) => element.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final CameraController cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      onCameraError(e);
      rethrow;
    }
    final XFile file = await cameraController.takePicture();
    return file;
  }

  void onCameraError(CameraException e) {
    switch (e.code) {
      case 'CameraAccessDenied':
        showInSnackBar('Vous avez refusé l\'accès à la caméra.');
        break;
      case 'CameraAccessDeniedWithoutPrompt':
        showInSnackBar(
            'Veuillez aller dans les paramètres pour activer l\'accès à la caméra.');
        break;
      case 'CameraAccessRestricted':
        showInSnackBar('L\'accès à la caméra est restreint.');
        break;
      case 'AudioAccessDenied':
        showInSnackBar('Vous avez refusé l\'accès à l\'audio.');
        break;
      case 'AudioAccessDeniedWithoutPrompt':
        showInSnackBar(
            'Veuillez aller dans les paramètres pour activer l\'accès à l\'audio.');
        break;
      case 'AudioAccessRestricted':
        showInSnackBar('L\'accès à l\'audio est restreint.');
        break;
      default:
        _showCameraException(e);
        break;
    }
  }
}
