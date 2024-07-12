import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/presence_provider.dart';

class QrScan extends StatefulWidget {
  final int? subjectHourId;
  final WidgetRef ref;

  QrScan({required this.subjectHourId, required this.ref});

  @override
  State<StatefulWidget> createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final code = scanData.code;
      final token = widget.ref.read(authenticationProvider);
      if (token != null) {
        final decodedToken = JwtDecoder.decode(token);
        final studentId = decodedToken['Student_Id'].toString();
        final message = "validate ${widget.subjectHourId} $studentId $code";
        final url = 'wss://apigessignrecette-c5e974013fbd.herokuapp.com/ws';
        widget.ref.read(presenceProvider.notifier).connectWebSocket(url);

        _showLoadingDialog(); // Show loading dialog

        widget.ref.read(presenceProvider.notifier).messages.listen((message) {
          Navigator.of(context).pop(); // Dismiss loading dialog

          if (message['action'] == 'VALIDATED') {
            _showSuccess("Présence validée avec succès.");
          } else if (message['action'] == 'ERROR') {
            _showError(message['message']);
          }
        });

        widget.ref.read(presenceProvider.notifier).sendMessage(message);
      } else {
        _showError("Token invalide");
      }

      Navigator.pop(context); // Close the QR scanner
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Connexion en cours..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    widget.ref.read(presenceProvider.notifier).disconnectWebSocket();
    super.dispose();
  }
}
