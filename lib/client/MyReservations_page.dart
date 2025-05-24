import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
    controller.fetchReservationsFromBackend();

    Future.delayed(Duration(seconds: 1), () {
      print('🔍 Liste des IDs des réservations :');
      for (var reservation in controller.reservations) {
        print('➡️ ID: ${reservation['id']}');
      }
      for (var reservation in controller.reservations) {
  print('➡️ ID: ${reservation['id']}');
  print('🧾 Contenu: ${jsonEncode(reservation)}');
}
    });

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
      final dateStr = reservation['date'];
      final timeStr = reservation['selectedExactTime'];
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
      final dateStr = reservation['date'];
      final timeStr = reservation['selectedExactTime'];
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
      return month != null ? "$year-$month-$day" : null;
    } catch (_) {
      return null;
    }
  }

IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'validé':
    case 'confirmed':
      return Icons.check_circle;
    case 'active':
      return Icons.access_time;
    case 'annulé':
    case 'cancelled':
      return Icons.cancel;
    case 'reported':
      return Icons.report;
    case 'no_confirmation':
      return Icons.warning;
    case 'finished':
      return Icons.flag;
    default:
      return Icons.help_outline;
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'validé':
    case 'confirmed':
      return Colors.green;
    case 'active':
      return Colors.orange;
    case 'annulé':
    case 'cancelled':
      return Colors.red;
    case 'reported':
      return Colors.deepPurple;
    case 'no_confirmation':
      return Colors.amber;
    case 'finished':
      return Colors.grey;
    default:
      return Colors.black38;
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

        final timeData = reservation['reservationTime'];
        final tableData = reservation['table'];

        final date = timeData?['date2'] ?? 'Date inconnue';
        final time = timeData?['startTime'] ?? 'Heure inconnue';
        final name = reservation['customerName'] ?? reservation['name'] ?? 'Nom inconnu';
final restaurantName = tableData?['restaurantBloc']?['restaurant']?['name'] ?? 'Restaurant inconnu';
final tables = tableData?['name']?.toString() ?? '—';
final chairs = tableData?['numChaises']?.toString() ?? '—';
       

        return Card(
            color: Colors.white, 
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          Text(name,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          rowItem(Icons.restaurant, 'Restaurant: $restaurantName'),
                          rowItem(Icons.calendar_today, date),
                          rowItem(Icons.access_time, time),
                          rowItem(Icons.table_bar, 'Table: $tables'),
                          rowItem(Icons.chair, 'Chaises: $chairs'),
                        ],
                      ),
                    ),
                    Icon(
                      getStatusIcon(reservation['status'] ?? ''),
                      color: getStatusColor(reservation['status'] ?? ''),
                      size: 40,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Get.to(() => EditReservationPage(reservation: reservation));
            },
            icon: Icon(Icons.edit, color: Colors.white),
            label: Text("Modifier", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: Text("Confirmation"),
                  content: Text("Voulez-vous vraiment annuler cette réservation ?"),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text("Annuler")),
                    ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        child: Text("Confirmer")),
                  ],
                ),
              );
              if (confirm == true) {
                await controller.markReservationAsCancelled(reservation);
                final notifCtrl = Get.find<NotificationsController>();
                notifCtrl.sendCancelNotification(name);
                Get.snackbar("Annulé", "Réservation annulée avec succès");
              }
            },
            icon: Icon(Icons.cancel, color: Colors.white),
            label: Text(getRemainingTimeText(reservation), style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    ),
    SizedBox(height: 10),
    ElevatedButton.icon(
onPressed: () {
Get.to(() => DetaileReservationPage(reservationDetails: reservation));
},      
      icon: Icon(Icons.info_outline, color: Colors.white),
      label: Text("Explorer la réservation", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  ],
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
class DetaileReservationPage extends StatelessWidget {
  final Map<String, dynamic> reservationDetails;

  const DetaileReservationPage({required this.reservationDetails, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeData = reservationDetails['reservationTime'] ?? {};
    final tableData = reservationDetails['table'] ?? {};

    final date = timeData['date2'] ?? '—';
    final time = timeData['startTime'] ?? '—';
    final table = tableData['name']?.toString() ?? '—';
    final chaises = tableData['numChaises']?.toString() ?? '—';
    final personnes = reservationDetails['nbPersonnes']?.toString() ?? '—';

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
            detailRow('📅 Date', date),
            detailRow('⏰ Créneau', time),
            detailRow('🪑 Tables', table),
            detailRow('🪑 Chaises', chaises),

            SizedBox(height: 30),
            Text(
              'QR Code de votre réservation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            qr_flutter.QrImageView(
              data: reservationDetails['id'] ?? 'ID manquant',
              size: 200,
              version: qr_flutter.QrVersions.auto,
              errorStateBuilder: (context, error) => Text(
                "Erreur QR",
                style: TextStyle(color: Colors.red),
              ),
            ),

            Spacer(),

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



class EditReservationPage extends StatefulWidget {
  final Map<String, dynamic> reservation;
  const EditReservationPage({required this.reservation, Key? key}) : super(key: key);

  @override
  State<EditReservationPage> createState() => _EditReservationPageState();
}

class _EditReservationPageState extends State<EditReservationPage> {
  final controller = Get.find<ConfirmationReservationController>();
  late String selectedDate = "";

  late String selectedTime;
  String? selectedRestaurantId;
  String? selectedRestaurantName;
  String? selectedTableId;
  String? selectedTableName;
  String? selectedView;

  List<String> views = ['SEA_VIEW', 'INDOOR', 'TERRACE'];

  @override
void initState() {
  super.initState();

  // ✅ Garde seulement cette version robuste
selectedDate = widget.reservation['reservationTime']?['date2'];
if (selectedDate == null || selectedDate.isEmpty) {
  selectedDate = DateTime.now().toIso8601String().split('T')[0];
}



  selectedTime = widget.reservation['reservationTime']?['startTime'] ?? '';
  selectedRestaurantName = widget.reservation['table']?['restaurantBloc']?['restaurant']?['name'];
  selectedRestaurantId = widget.reservation['table']?['restaurantBloc']?['restaurant']?['id'];
  selectedTableName = widget.reservation['table']?['name'];
  selectedTableId = widget.reservation['table']?['id'];
  selectedView = widget.reservation['table']?['view'];

  controller.fetchRestaurants().then((_) {
    if (!controller.restaurants.any((r) => r['id'] == selectedRestaurantId)) {
      setState(() {
        selectedRestaurantName = null;
        selectedRestaurantId = null;
      });
    } else {
      controller.fetchTables(selectedRestaurantId!);
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Modifier la réservation"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.restaurants.isEmpty) {
          return Center(child: Text("Aucun restaurant trouvé ❌"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📍 Restaurant", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: selectedRestaurantId,
                items: controller.restaurants.map<DropdownMenuItem<String>>((resto) {
                  return DropdownMenuItem<String>(
                    value: resto['id'],
                    child: Text(resto['name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  selectedRestaurantId = val;
                  final selected = controller.restaurants.firstWhere((r) => r['id'] == val);
                  selectedRestaurantName = selected['name'];
                  controller.fetchTables(val!);
                  selectedTableId = null;
                  selectedTableName = null;
                }),
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),

              SizedBox(height: 16),
              Text("🌭 Vue", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: views.contains(selectedView) ? selectedView : null,
                items: views.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (val) => setState(() => selectedView = val),
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),

              SizedBox(height: 16),
              Text("🪑 Table", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => ListView(
                      shrinkWrap: true,
                      children: controller.tables.map((t) {
                        return ListTile(
                          title: Text('${t['name']} - ${t['view']}'),
                          onTap: () {
                            setState(() {
                              selectedTableId = t['id'];
                              selectedTableName = t['name'];
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
                icon: Icon(Icons.table_bar, color: Colors.white),
                label: Text(
                  selectedTableName ?? "Choisir la table",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
GestureDetector(
  onTap: () async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked.toIso8601String().split('T')[0]; // format YYYY-MM-DD
      });
    }
  },
  child: AbsorbPointer(
    child: TextFormField(
      controller: TextEditingController(text: selectedDate),
      decoration: InputDecoration(
        hintText: 'jj-mm-aaaa',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
    ),
  ),
),

              SizedBox(height: 16),
              Text("⏰ Heure", style: TextStyle(fontWeight: FontWeight.bold)),
ElevatedButton.icon(
  onPressed: () async {
   final time = await showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    );
  },
);

    if (time != null) {
      final formatted24h = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
      setState(() => selectedTime = formatted24h);
    }
  },
  icon: Icon(Icons.access_time, color: Colors.white),
  label: Text(
    selectedTime.isNotEmpty ? selectedTime.substring(0, 5) : "Choisir l'heure",
    style: TextStyle(color: Colors.white),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    minimumSize: Size(double.infinity, 50),
  ),
),


              
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
  if (selectedDate == null || selectedDate.isEmpty) {
    Get.snackbar("Erreur", "La date de réservation est invalide");
    return;
  }

if (selectedDate == null || selectedDate.isEmpty || selectedTime.isEmpty || selectedTableId == null) {
  Get.snackbar("Erreur", "Certains champs sont manquants ou invalides.");
  return;
}
  await controller.checkAndUpdateReservation(
    reservationId: widget.reservation['id'],
    restaurantId: selectedRestaurantId!,
    tableId: selectedTableId!,
    time: selectedTime,
    date: selectedDate,
  );
},



                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text("Confirmer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.red),
                      label: Text("Annuler", style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
