import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add Get package for dark mode handling
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanClientPage extends StatefulWidget {
  const ScanClientPage({super.key});

  @override
  _ScanClientPageState createState() => _ScanClientPageState();
}

class _ScanClientPageState extends State<ScanClientPage> {
  String? qrCodeResult;

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
                    onQRScanned: (String result) {
                      Navigator.pop(context); // Ferme le dialog après scan
                      if (mounted) {
                        setState(() {
                          qrCodeResult = result;
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

  Widget _buildQRResultWidget(bool isDarkMode) {
    if (qrCodeResult == null) {
      return Container(); // Rien à afficher avant le scan
    }

    bool isValid = qrCodeResult == "123456789"; 
    bool isInvalid = qrCodeResult == "987654321"; 

    return Column(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 100,
        ),
        Text(
          isValid
              ? "✅ QR Code Valide"
              : isInvalid
                  ? "❌ QR Code Invalide"
                  : "⚠️ QR Code Inconnu",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isValid ? Colors.green : Colors.red,
          ),
        ),
        if (!isValid && !isInvalid) ...[ 
          const SizedBox(height: 10),
          Text(
            "Le QR code scanné n'est pas reconnu.",
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ]
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
          mainAxisAlignment: MainAxisAlignment.center, // Centrer verticalement
          crossAxisAlignment: CrossAxisAlignment.center, // Centrer horizontalement
          children: [
            // Texte centré avec emoji
            Text(
              "Scanner le QR code pour vérifier la réservation 📱",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center, // Assure que le texte est centré
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
