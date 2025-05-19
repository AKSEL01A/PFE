import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import 'package:reservini/controllers/confirmation_reservation_controller.dart';
import 'package:reservini/controllers/notifications_controller.dart';

class MyReservationsPage extends StatefulWidget {
  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final ConfirmationReservationController controller = Get.find();
  late Timer _timer;

  @override
void initState() {
  super.initState();

  // ✅ Impression des ID des réservations
  Future.delayed(Duration.zero, () {
    print('🔍 Liste des IDs des réservations :');
    for (var reservation in controller.reservations) {
      print('➡️ ID: ${reservation['id']}');
    }
  });

  // Refresh UI chaque seconde
  _timer = Timer.periodic(Duration(seconds: 1), (_) {
    if (mounted) setState(() {});
  });
}


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool canCancel(Map<String, dynamic> reservation) {
    try {
      final details = reservation['details'];
      final dateStr = details['date'];
      final timeStr = details['selectedExactTime'];
      if (dateStr == null || timeStr == null) return false;

      final isoDate = convertFrenchDateToIso(dateStr);
      if (isoDate == null) return false;

      final fullDateTime = DateTime.parse('$isoDate $timeStr:00');
      final now = DateTime.now();
      final diff = fullDateTime.difference(now);

      return diff.inHours >= 2 && diff.inHours <= 24;
    } catch (_) {
      return false;
    }
  }

  String getRemainingTimeText(Map<String, dynamic> reservation) {
    try {
      final details = reservation['details'];
      final dateStr = details['date'];
      final timeStr = details['selectedExactTime'];

      if (dateStr == null || timeStr == null) return "Annuler";
      final isoDate = convertFrenchDateToIso(dateStr);
      if (isoDate == null) return "Date invalide";

      final fullDateTime = DateTime.parse('$isoDate $timeStr:00');
      final now = DateTime.now();
      final diff = fullDateTime.difference(now);

      if (diff.inSeconds <= 0) return "⛔ Temps écoulé";
      if (diff.inHours > 24) return "🕒 Timer actif 24h avant";

      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      return "Annuler ($h:$m:$s)";
    } catch (_) {
      return "Erreur timer";
    }
  }

  String? convertFrenchDateToIso(String frenchDate) {
    final mois = {
      'janvier': '01', 'février': '02', 'mars': '03', 'avril': '04',
      'mai': '05', 'juin': '06', 'juillet': '07', 'août': '08',
      'septembre': '09', 'octobre': '10', 'novembre': '11', 'décembre': '12'
    };
    try {
      final parts = frenchDate.toLowerCase().split(' ');
      final day = parts[0].padLeft(2, '0');
      final month = mois[parts[1]];
      final year = parts[2];
      if (month == null) return null;
      return "$year-$month-$day";
    } catch (_) {
      return null;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Validé':
        return Icons.check_circle;
      case 'En cours':
        return Icons.access_time;
      case 'Annulé':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Validé':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'Annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget rowItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mes Réservations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.reservations.length,
            itemBuilder: (context, index) {
              final reservation = controller.reservations[index];
              final details = reservation['details'];

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(reservation['name'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                rowItem(Icons.calendar_today, reservation['date']),
                                rowItem(Icons.table_bar, 'Tables: ${reservation['tables']}'),
                                rowItem(Icons.chair, 'Chaises: ${reservation['chairs']}'),
                              ],
                            ),
                          ),
                          Icon(
                            getStatusIcon(reservation['status']),
                            color: getStatusColor(reservation['status']),
                            size: 40,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar("Modification", "Ouverture de l'édition...");
                              },
                              icon: Icon(Icons.edit, color: Colors.white),
                              label: Text("Modifier", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
  child: ElevatedButton.icon(
   onPressed: () async {
  final confirm = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Confirmation", style: TextStyle(color: Colors.black)),
      content: Text("Voulez-vous vraiment annuler cette réservation ?", style: TextStyle(color: Colors.black)),
      actions: [
        // ❌ Bouton Annuler (fond blanc + texte rouge + bordure rouge)
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: BorderSide(color: Colors.red),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Get.back(result: false),
          child: Text("Annuler", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        // ✅ Bouton Confirmer (fond noir + texte blanc)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Get.back(result: true),
          child: Text("Confirmer", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  if (confirm == true) {
await controller.markReservationAsCancelled(reservation);
    final notifCtrl = Get.find<NotificationsController>();
    notifCtrl.sendCancelNotification(reservation['name']);
    Get.snackbar("Annulé", "Réservation annulée avec succès");
  }
},


    icon: Icon(Icons.cancel, color: Colors.white),
    label: Text(
      getRemainingTimeText(reservation),
      style: TextStyle(color: Colors.white),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      disabledBackgroundColor: const Color.fromARGB(255, 255, 0, 0),
      padding: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => DetaileReservationPage(reservationDetails: details));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Explorer', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }
}


  Widget rowItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }


class DetaileReservationPage extends StatelessWidget {
  final Map<String, dynamic> reservationDetails;

  const DetaileReservationPage({required this.reservationDetails, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de la réservation"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 10),
            detailRow('📅 Date', reservationDetails['date']),
            detailRow('⏰ Créneau', reservationDetails['timeSlot']),
            detailRow('🪑 Tables', reservationDetails['tables']),
            detailRow('👥 Personnes', reservationDetails['peopleCount'].toString()),
            detailRow('🪑 Chaises', reservationDetails['chairsCount'].toString()),
            detailRow('📝 Note', reservationDetails['note'] ?? '—'),

            SizedBox(height: 30),

            Text(
              'QR Code de votre réservation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            qr_flutter.QrImageView(
              data: jsonEncode(reservationDetails),
              size: 200,
              version: qr_flutter.QrVersions.auto,
              errorStateBuilder: (context, error) => Text(
                "Erreur QR",
                style: TextStyle(color: Colors.red),
              ),
            ),

            Spacer(),

            // ✅ Bouton de retour à l'accueil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => MyReservationsPage());
                },
                icon: Icon(Icons.home),
                label: Text("Retour"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
