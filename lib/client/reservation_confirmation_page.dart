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
    return Scaffold(
      backgroundColor: Colors.white,
     
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
                        SizedBox(height: 30),
            // Titre principal
            Text(
              'Votre réservation a été confirmée 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 30),

            // Détails de la réservation
            buildDetail('📅 Date', reservationDetails['date']),
            buildDetail('⏰ Créneau', reservationDetails['timeSlot']),
            buildDetail('🪑 Tables', reservationDetails['tables']),
            buildDetail('👥 Personnes', reservationDetails['peopleCount'].toString()),
            buildDetail('🪑 Chaises', reservationDetails['chairsCount'].toString()),
            buildDetail('📝 Note', reservationDetails['note']),

            SizedBox(height: 30),

            // QR Code
            Center(
              child: qr_flutter.QrImageView(
                data: jsonEncode(reservationDetails),
                size: 200.0,
                version: qr_flutter.QrVersions.auto,
                errorStateBuilder: (context, error) {
                  return Text(
                    "Erreur de génération du QR code",
                    style: TextStyle(color: Colors.red),
                  );
                },
              ),
            ),

            Spacer(),

            // Bouton bas de page
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
  final reservationController = Get.find<ConfirmationReservationController>();

  final now = DateTime.now();
  final reservationId = now.millisecondsSinceEpoch;

  final newReservation = {
    'name': 'Réservation #$reservationId',
    'date': reservationDetails['date'],
    'tables': reservationDetails['tables'],
    'chairs': reservationDetails['chairsCount'],
    'status': 'Validé',
    'details': reservationDetails,
    'qrData': jsonEncode(reservationDetails), // ← ajouter QR code ici
  };

  reservationController.reservations.add(newReservation);

  Get.offAllNamed('/home');
},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                icon: Icon(Icons.home),
                label: Text(
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
