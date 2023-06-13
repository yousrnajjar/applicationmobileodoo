import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

//getExternalStorageDirectory
import 'package:path_provider/path_provider.dart';
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
      await saveFile(
        context: context,
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

Future<void> saveFile({
  required BuildContext context,
  required Uint8List bytes,
  required String fileName,
}) async {
  // get path to save file
  Directory? directory = await getExternalStorageDirectory();
  String path = directory!.path;
  // save file
  File file = File('$path/$fileName.pdf');
  await file.writeAsBytes(bytes);
  if (context.mounted) {
    // show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("File saved to $path/$fileName.pdf"),
      ),
    );
  }
}
