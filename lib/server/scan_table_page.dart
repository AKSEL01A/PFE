import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add Get package for dark mode handling
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanTablePage extends StatefulWidget {
  const ScanTablePage({super.key});

  @override
  _ScanTablePageState createState() => _ScanTablePageState();
}

class _ScanTablePageState extends State<ScanTablePage> {
  String? qrCodeResult;
  String? nextAvailableTime; // Stores the next available time for the table

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
                  "Scanner le QR Code de la Table",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Expanded(
                  child: QRScannerScreen(
                    onQRScanned: (String result) {
                      Navigator.pop(context); // Ferme le dialog après scan
                      if (mounted) {
                        setState(() {
                          qrCodeResult = result;
                          _checkTableAvailability(result); // Check table status
                        });
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

  // Simulated table availability check
  void _checkTableAvailability(String scannedCode) {
    if (scannedCode.startsWith("TABLE_")) {
      bool isAvailable = scannedCode != "TABLE_3"; // Example: Table_3 is occupied

      setState(() {
        nextAvailableTime = isAvailable ? null : "Disponible à 20h00"; // Hardcoded availability
      });
    } else {
      setState(() {
        nextAvailableTime = null;
      });
    }
  }

  Widget _buildQRResultWidget(bool isDarkMode) {
    if (qrCodeResult == null) {
      return Container(); // No result yet
    }

    bool isValid = qrCodeResult!.startsWith("TABLE_");
    bool isAvailable = nextAvailableTime == null;

    return Column(
      children: [
        Icon(
          isValid
              ? (isAvailable ? Icons.check_circle : Icons.access_time)
              : Icons.cancel,
          color: isValid
              ? (isAvailable ? Colors.green : Colors.orange)
              : Colors.red,
          size: 100,
        ),
        Text(
          isValid
              ? (isAvailable ? "Table disponible ✅" : "Table occupée ⏳")
              : "QR Code Invalide ❌",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isValid
                ? (isAvailable ? Colors.green : Colors.orange)
                : Colors.red,
          ),
        ),
        if (!isAvailable && isValid) ...[
          const SizedBox(height: 10),
          Text(
            "Prochaine disponibilité : $nextAvailableTime",
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
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
          children: [
            // Texte centré
            Text(
              "Scanner le QR code pour identifier la table",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Bouton centré avec une icône et un texte
            Container(
              width: 250, // Largeur du bouton
              height: 150, // Hauteur du bouton
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.black,
                borderRadius: BorderRadius.circular(20), // Coins arrondis
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
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // Supprimer le padding par défaut
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Centrer le contenu verticalement
                  crossAxisAlignment: CrossAxisAlignment.center, // Centrer le contenu horizontalement
                  children: [
                    Icon(
                      Icons.camera_alt, // Icône de caméra
                      color: Colors.white,
                      size: 40,  // Taille de l'icône
                    ),
                    const SizedBox(height: 10), // Espace entre l'icône et le texte
                    Text(
                      "Scanner QR-Code",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildQRResultWidget(isDarkMode), // Affichage du résultat
          ],
        ),
      ),
    );
  }
}

// Widget pour scanner le QR Code
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
        widget.onQRScanned(scanData.code!); // ✅ Convertit en String
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }
}
