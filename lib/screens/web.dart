// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/enum.dart';

/// Barcode scanner for web using iframe
class BarcodeScanner extends StatelessWidget {
  final ScanType scanType;
  final Future Function(String) onScanned;

  const BarcodeScanner({
    Key? key,
    required this.scanType,
    required this.onScanned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String createdViewId = DateTime.now().microsecondsSinceEpoch.toString();
    String? barcodeNumber;

    final html.IFrameElement iframe = html.IFrameElement()
      ..style.borderRadius = '10'
      ..src = PackageConstant.barcodeFileWebPath
      ..style.border = 'none'
      ..onLoad.listen((event) async {
        /// Barcode listener on success barcode scanned
        html.window.onMessage.listen((event) {
          /// If barcode is null then assign scanned barcode
          /// and close the screen otherwise keep scanning
          if (barcodeNumber == null) {
            barcodeNumber = event.data;
            onScanned(barcodeNumber!);
          }
        });
      });
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(createdViewId, (int viewId) => iframe);

    return HtmlElementView(
      viewType: createdViewId,
    );
  }
}
