import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/presence_provider.dart';
import '../../service/provider/daily_course_provider.dart';

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
  late ConfettiController _confettiController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    controller?.dispose();
    _confettiController.dispose();
    widget.ref.read(presenceProvider.notifier).disconnectWebSocket();
    super.dispose();
  }

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
      body: Stack(
        children: [
          QRView(
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
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!_isProcessing) {
        _isProcessing = true;
        final code = scanData.code;
        final token = widget.ref.read(authenticationProvider);
        if (token != null) {
          final decodedToken = JwtDecoder.decode(token);
          final studentId = decodedToken['Student_Id'].toString();
          final Valitedmessage = "validate ${widget.subjectHourId} $studentId $code";
          final url = 'wss://apigessignrecette-c5e974013fbd.herokuapp.com/ws';
          widget.ref.read(presenceProvider.notifier).connectWebSocket(url);

          _showLoadingDialog(); // Show loading dialog
          widget.ref.read(presenceProvider.notifier).sendMessage(Valitedmessage);
          widget.ref.read(presenceProvider.notifier).messages.listen((message) async {
            Navigator.of(context).pop(); // Dismiss loading dialog

            if (message['action'] == 'VALIDATED') {
              _confettiController.play();
              await _updateCoursePresence(widget.subjectHourId!);
              Future.delayed(const Duration(seconds: 3), () {
                Navigator.pop(context); // Return to MainPage
              });
            } else if (message['action'] == 'ERROR') {
              _showError(message['message']);
            }
            _showError(message);
            //_isProcessing = false;
          });
        } else {
          _showError("Token invalide");
        }
      }
    });
  }

  Future<void> _updateCoursePresence(int subjectHourId) async {
    widget.ref.read(dailyCourseProvider.notifier).markAsPresent(subjectHourId);
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
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Return to MainPage
              },
            ),
          ],
        );
      },
    );
  }
}
