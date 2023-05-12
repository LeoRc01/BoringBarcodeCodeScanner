library simple_barcode_scanner;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/shared.dart';

export 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class SimpleBarcodeScannerPage extends StatelessWidget {

  final ScanType scanType;
  final Future Function(String)? onScanned;

  const SimpleBarcodeScannerPage(
      {Key? key, this.scanType = ScanType.barcode, this.onScanned})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarcodeScanner(
      scanType: scanType,
      onScanned: (res) async {
        await onScanned?.call(res);
      },
    );
  }
}
