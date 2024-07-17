import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:token_system/database/Firebase.dart';

class scannerPage extends StatefulWidget {
  const scannerPage({super.key});

  @override
  State<scannerPage> createState() => _scannerPageState();
}

class _scannerPageState extends State<scannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: const Text(
            'Scan QR',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: onQRViewCamera,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onQRViewCamera(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      if (result != null) {
        await handleQRCodeResult(result!.code!);
      }
    });
  }

  Future<void> handleQRCodeResult(String qrCodeData) async {
    List<String> parts = qrCodeData.split(' ');
    if (parts.length != 3) return;

    String roll = parts[0]; 
    String type = parts[1].toLowerCase(); 
    int count = int.tryParse(parts[2]) ?? 0;

    if (count > 0) {
      List<int> token = [0, 0, 0];
      if (type == 'veg') {
        token[1] = count;
      } else if (type == 'nonveg') {
        token[0] = count;
      } else if (type == 'eggs') {
        token[2] = count;
      }

      List<dynamic> result =
          await Firestore().checkAndDecrementTokenData(token, roll);

      if (result[0] == 'already_used') {
        showAlert(context, 'Error', 'Token already used or not bought.');
      } else if (result[0] == 'success') {
        print('Updated values: ${result.sublist(1)}');
      } else if (result[0] == 'not_exist') {
        showAlert(context, 'Error', 'Roll number does not exist.');
      } else if (result[0] == 'error') {
        showAlert(context, 'Error',
            'An unexpected error occurred. Please try again.');
      }
    }
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
