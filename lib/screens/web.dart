// ignore: avoid_web_libraries_in_flutter
import 'dart:developer';
import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/enum.dart';

/// Barcode scanner for web using iframe
///
///
///

@JS('getAvailableCameras')
external dynamic getAvailableCameras();

@JS('switchCamera')
external void switchCamera(String id);

@JS('Html5Qrcode.getCameras')
external void getCameras();

///
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

    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder(
              future: getCamerasID(),
              builder: (ctx, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                }

                return Row(
                  children: snapshot.data!
                      .map(
                        (e) => ElevatedButton(
                            onPressed: () async {
                              switchCamera(e);
                            },
                            child: Text(e.substring(0, 6))),
                      )
                      .toList(),
                );
              }),
          ElevatedButton(
              onPressed: () async {
                getCameras();
              },
              child: const Text('asdsda')),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 400,
            width: 400,
            child: HtmlElementView(
              viewType: createdViewId,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> getCamerasID() async {
    try {
      final result = await js_util.promiseToFuture(getAvailableCameras());
      return result.toString().split('@').toList();
    } catch (e) {
      log('Camera error: $e');
      return [];
    }
  }
}
