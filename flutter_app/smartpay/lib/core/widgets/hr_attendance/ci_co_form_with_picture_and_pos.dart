import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartpay/core/widgets/utils/camera/face_picture_take.dart';
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
    var att = await super.checkIn();
    if (context.mounted) {
      XFile imageFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => FacePictureTakeWidget(
            onPictureTaken: (file) {
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop(file);
              }
            },
          ),
        ),
      );
      final path = imageFile.path;
      final Uint8List bytes = await File(path).readAsBytes();
      Position position = await PositionGetter.position;
      await attendance.addImageAndPosition(bytes, position);
    }
    return att;
  }
}
