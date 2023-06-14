import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/download_pdf.dart';
import 'package:smartpay/ir/model.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AppPDFView extends StatefulWidget {
  final String reportName;
  final List<int> resourceIds;
  final Function? onReturn;

  const AppPDFView(
      {super.key,
      required this.reportName,
      required this.resourceIds,
      this.onReturn});

  @override
  State<AppPDFView> createState() => _AppPDFViewState();
}

class _AppPDFViewState extends State<AppPDFView> {
  int _page = 0;
  int _pageCount = 0;
  Uint8List? _pdfBytes;

  Future<Uint8List> _loadPdfInBytes() async {
    try {
      String bytesAsString = await OdooModel.renderPdfReport(
        reportName: widget.reportName,
        resourceIds: widget.resourceIds,
      );
      List<int> bytes = bytesAsString.codeUnits;
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPdfInBytes().then((value) {
      setState(() {
        _pdfBytes = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String navigationText = '$_page / $_pageCount';
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 30,
            color: kLightGrey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(navigationText),
                // Vertical line as separator
                SizedBox(width: 10),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.black,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    if (widget.onReturn != null) {
                      widget.onReturn!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: kGrey.withOpacity(0.6),
              padding: const EdgeInsets.all(20),
              child: (_pdfBytes != null)
                  ? SfPdfViewer.memory(
                      _pdfBytes!,
                      initialScrollOffset: Offset(0, 0),
                      initialZoomLevel: 1.5,
                      pageSpacing: 2,
                      canShowScrollHead: true,
                      onDocumentLoaded: (details) {
                        setState(() {
                          _page = 1;
                          _pageCount = details.document.pages.count;
                        });
                      },
                      onPageChanged: (details) {
                        setState(() {
                          _page = details.newPageNumber;
                        });
                      },
                      onDocumentLoadFailed: (details) {
                        showErrorDialog(context, details.error);
                      },
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                child: const Text('Imprimer'),
                onPressed: () {
                  if (widget.onReturn != null) {
                    widget.onReturn!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              ElevatedButton(
                child: const Text('Télécharger'),
                onPressed: () {
                  var file = FileStorage.saveFile(
                      bytes: _pdfBytes!, fileName: widget.reportName);
                  // Show toast
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PDF téléchargé'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showErrorDialog(BuildContext context, Object error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
