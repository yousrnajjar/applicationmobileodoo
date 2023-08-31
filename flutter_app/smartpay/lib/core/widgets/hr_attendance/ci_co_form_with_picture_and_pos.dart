import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartpay/core/widgets/utils/camera/take_picture_without_preview.dart';
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
  Future<Map<String, dynamic>> checkIn() async {
    final Uint8List bytes = await takePicture();
    Position position = await PositionGetter.position;
    var att = await super.checkIn();
    await attendance.addImageAndPosition(bytes, position);
    return att;
  }

  @override
  Future<Map<String, dynamic>> checkOut() async {
    final Uint8List bytes = await takePicture();
    Position position = await PositionGetter.position;
    var att = await super.checkOut();
    await attendance.addImageAndPosition(bytes, position, isCheckOut: true);
    return att;
  }

  Future<Uint8List> takePicture() async {
    XFile imageFile = await takePictureWithoutPreview();
    final path = imageFile.path;
    final Uint8List bytes = await File(path).readAsBytes();
    return bytes;
  }
}
