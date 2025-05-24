import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get_connect.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanClientPage extends StatefulWidget {
  const ScanClientPage({super.key});

  @override
  _ScanClientPageState createState() => _ScanClientPageState();
}

class _ScanClientPageState extends State<ScanClientPage> {
  String? qrCodeResult;
  final getConnect = GetConnect();

  void _openQRScannerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final bool isDarkMode = Get.isDarkMode;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          child: SizedBox(
            height: 400,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Scanner le QR Code",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Expanded(
                  child: QRScannerScreen(
                    onQRScanned: (String result) async {
                      Navigator.pop(context); // Fermer le scanner

                      final reservation = await checkQRCodeFromServer(result);
                      if (reservation != null) {
                        setState(() {
                          qrCodeResult = reservation['id'];
                        });

                        // Aller vers page détails si tu veux
                        Get.to(() => ReservationDetailsPage(reservation: reservation));
                      } else {
                        setState(() {
                          qrCodeResult = 'INVALID';
                        });
                        Get.snackbar('Erreur', 'QR Code invalide ou non trouvé');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> checkQRCodeFromServer(String reservationId) async {
    try {
      final response = await getConnect.get(
        'https://restaurant-back-main.onrender.com/reservations/confirm/$reservationId',
        headers: {
          'Authorization': 'Bearer ${GetStorage().read('token')}',
        },
      );

      if (response.statusCode == 200) {
        return response.body['reservation'];
      } else {
        return null;
      }
    } catch (e) {
      print("Erreur QR: $e");
      return null;
    }
  }

  Widget _buildQRResultWidget(bool isDarkMode) {
    if (qrCodeResult == null) return Container();

    if (qrCodeResult == 'INVALID') {
      return Column(
        children: [
          Icon(Icons.cancel, color: Colors.red, size: 100),
          Text("❌ QR Code Invalide", style: TextStyle(fontSize: 18, color: Colors.red)),
        ],
      );
    }

    return Column(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 100),
        Text("✅ QR Code Valide", style: TextStyle(fontSize: 18, color: Colors.green)),
        Text("ID Réservation : $qrCodeResult", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Scanner le QR code pour vérifier la réservation 📱",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _openQRScannerDialog,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 40),
                    const SizedBox(height: 10),
                    Text("Scanner QR-Code", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildQRResultWidget(isDarkMode),
          ],
        ),
      ),
    );
  }
}

// Scanner widget
class QRScannerScreen extends StatefulWidget {
  final Function(String) onQRScanned;
  const QRScannerScreen({required this.onQRScanned, super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        widget.onQRScanned(scanData.code!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return QRView(key: qrKey, onQRViewCreated: _onQRViewCreated);
  }
}

// --- Page détails (à créer) ---
class ReservationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailsPage({required this.reservation, super.key});

  @override
  Widget build(BuildContext context) {
    final time = reservation['reservationTime'];

    return Scaffold(
      appBar: AppBar(title: Text("Détails Réservation")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 Client : ${reservation['customerName']}"),
            Text("📞 Téléphone : ${reservation['phone']}"),
            Text("📅 Date : ${time['date2']}"),
            Text("🕒 De : ${time['startTime']} à ${time['endTime']}"),
          ],
        ),
      ),
    );
  }
}
