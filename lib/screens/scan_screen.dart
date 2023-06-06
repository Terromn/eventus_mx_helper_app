import 'dart:io';

import 'package:eventus_mx_helper_app/screens/verify_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  Barcode? barcode;
  String qrText = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller.pauseCamera();
    }

    if (Platform.isIOS) {
      await controller.pauseCamera();
    }

    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Scaffold(
        backgroundColor: const Color(0xFF0A0813),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildQrView(context),
            Positioned(top: 100, child: buildResult()),
            Positioned(
              bottom: 100,
              child: ElevatedButton(
                onPressed: () {
                  if (barcode != null) {

                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerifyCodeScreen(qrInfo: barcode!.code),
                    ),
                  );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se ha detectado ningun codigo...'),
                        backgroundColor: Color(0xFF5400DA)
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFF5400DA)), // Set the background color
                  textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 16)), // Set the text style
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(12)), // Set the padding
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100))),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Text('Verificar Boleto'),
                ),
              ),
            )
          ],
        ),
      ));

  Widget buildResult() => Container(
        width: MediaQuery.of(context).size.width * .7,
        decoration: BoxDecoration(
          color: const Color(0xFF5400DA),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Text(
          barcode != null ? '${barcode!.code}' : 'Scanee un codigo',
          maxLines: 3,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          borderColor: const Color(0xFF5400DA),
          cutOutSize: MediaQuery.of(context).size.width * .8,
        ),
      );

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((barcode) {
      setState(() {
        this.barcode = barcode;
      });
    });
  }
}
