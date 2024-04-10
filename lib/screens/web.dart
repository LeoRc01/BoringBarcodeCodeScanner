// ignore: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/enum.dart';

class BarcodeScanner extends StatelessWidget {
  final String? lineColor;
  final String? cancelButtonText;
  final bool? isShowFlashIcon;
  final ScanType scanType;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;

  const BarcodeScanner({
    Key? key,
    this.lineColor,
    this.cancelButtonText,
    this.isShowFlashIcon,
    required this.scanType,
    required this.onScanned,
    this.appBarTitle,
    this.centerTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String createdViewId = '1';
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
