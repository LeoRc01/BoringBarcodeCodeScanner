library simple_barcode_scanner;

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/shared.dart';

export 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class SimpleBarcodeScannerPage extends StatelessWidget {

  final ScanType scanType;
  final Future Function(String)? returnValue;

  const SimpleBarcodeScannerPage(
      {Key? key, this.scanType = ScanType.barcode, this.returnValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarcodeScanner(
      scanType: scanType,
      onScanned: (res) async {
        await returnValue?.call(res);
      },
    );
  }
}
