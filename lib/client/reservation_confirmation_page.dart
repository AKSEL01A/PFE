import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import 'package:reservini/controllers/confirmation_reservation_controller.dart';

class ReservationConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> reservationDetails;

  const ReservationConfirmationPage({
    required this.reservationDetails,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
final qrData = reservationDetails['id'];

print("🧾 Données QR reçues : $qrData");
print("📦 ID reçu du backend : ${reservationDetails['id']}");



    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Text(
              'Votre réservation a été confirmée 🎉',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            buildDetail('📅 Date', reservationDetails['date']),
            buildDetail('⏰ Créneau', reservationDetails['timeSlot']),
            buildDetail('🪑 Tables', reservationDetails['tables']),
            buildDetail('👥 Personnes', reservationDetails['peopleCount'].toString()),
            buildDetail('🪑 Chaises', reservationDetails['chairsCount'].toString()),
            buildDetail('📝 Note', reservationDetails['note']),

            const SizedBox(height: 30),

            const Text(
              '🎫 QR Code de votre réservation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            qrData != null && qrData.toString().isNotEmpty
    ? qr_flutter.QrImageView(
        data: qrData.toString(), // on affiche l'ID directement
        size: 200,
        version: qr_flutter.QrVersions.auto,
        errorStateBuilder: (context, error) => const Text(
          "Erreur QR",
          style: TextStyle(color: Colors.red),
        ),
      )
    : const Text(
        "QR Code non disponible ❌",
        style: TextStyle(color: Colors.red),
      ),


            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final controller = Get.find<ConfirmationReservationController>();

                  final newReservation = {
                    'name': 'Réservation du ${reservationDetails['date']}',
                    'date': reservationDetails['date'],
                    'tables': reservationDetails['tables'],
                    'chairs': reservationDetails['chairsCount'],
                    'status': 'Validé',
                    'details': reservationDetails,
                    'qrData': reservationDetails['qrCode'],
                  };

                  controller.reservations.add(newReservation);
                  Get.offAllNamed('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text(
                  "Aller à l'accueil",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
