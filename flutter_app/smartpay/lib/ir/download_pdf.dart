import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartpay/ir/model.dart';

/// function to download pdf
///
/// [context] is the context of the widget
/// [reportName] is the name of the report to be downloaded
/// [resourceIds] is the list of ids of the records to be downloaded

Future<void> download({
  required BuildContext context,
  required String reportName,
  required List<int> resourceIds,
}) async {
  try {
    String bytesAsString = await OdooModel.renderPdfReport(
      reportName: reportName,
      resourceIds: resourceIds,
    );
    // save file
    List<int> bytes = bytesAsString.codeUnits;
    Uint8List pdfBytes = Uint8List.fromList(bytes);
    if (context.mounted) {
      await FileStorage.saveFile(
        bytes: pdfBytes,
        fileName: reportName,
      );
    }
  } catch (e) {
    throw Exception('Error parsing asset file!');
  }
}

/// function to save file
///
/// [context] is the context of the widget
/// [bytes] is the bytes of the file to be saved
/// [fileName] is the name of the file to be saved

// To save the file in the device
class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    // To check whether permission is given for this app or not.
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // If not we will ask for permission first
      await Permission.storage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      // Redirects it to download folder in android
      _directory = Directory("/storage/emulated/0/Download");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    // final directory = await getApplicationDocumentsDirectory();
    // return directory.path;
    // To get the external path from device of download folder
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> writeCounter(String bytes, String name) async {
    final path = await _localPath;
    // Create a file for the path of
    // device and file name with extension
    File file = File('$path/$name');
    ;
    print("Save file");

    // Write the data in the file you have created
    return file.writeAsString(bytes);
  }

  static Future<File> saveFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    // get path to save file
    final path = await _localPath;
    // Create file
    File file = File('$path/$fileName.pdf');
    return file.writeAsBytes(bytes);
  }
}
