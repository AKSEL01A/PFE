import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reservini/controllers/table_reservation_controller.dart'; // Import du controller pour la gestion des réservations

class AddReservationPage extends StatefulWidget {
  const AddReservationPage({super.key});

  @override
  _AddReservationPageState createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  late final TableReservationController controller;

  DateTime selectedDate = DateTime.now().add(Duration(days: 1));
  String? selectedExactTime;
  String selectedTimeSlot = 'Déjeuner';

  @override
  void initState() {
    super.initState();
    controller = Get.put(TableReservationController());
    controller.selectedDate.value = selectedDate;
    //controller.fetchTables(); // Charger les tables disponibles
  }


    List<String> getTimeOptions(String slot) {
    switch (slot) {
      case 'Matin':   return ['08:00','09:00','10:00','11:00'];
      case 'Déjeuner':return ['12:00','13:00','14:00','15:00','16:00','17:00'];
      case 'Dîner':   return ['18:00','19:00','20:00','21:00','22:00','23:00','00:00'];
      default:        return [];
    }
  }

  final Map<String,String> timeRanges = {
    'Matin'  : '08:00 - 12:00',
    'Déjeuner': '12:00 - 18:00',
    'Dîner'  : '18:00 - 01:00',
  };
  // Table UI build
  Widget buildTable(TableModel t) {
    final isSel = t.selected;
    final label = t.name ?? t.id.substring(0, 4);
    return GestureDetector(
      onTap: () {
        setState(() => t.selected = !t.selected);
        controller.tables.refresh();
      },
      child: Container(
        width: 50,
        height: 50,
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSel ? Colors.green : Colors.white,
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSel ? Colors.white : Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Build the table sections (zone A, B, C)
  Widget buildZone(String title, List<TableModel> list) {
    if (list.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text("❌ Aucune table disponible.", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 24),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: list.map(buildTable).toList(),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  // Date picker UI
  Widget buildDateSelector() {
    final days = List.generate(7, (i) {
      final d = DateTime.now().add(Duration(days: i));
      final sel = d.year == selectedDate.year &&
          d.month == selectedDate.month &&
          d.day == selectedDate.day;

      return GestureDetector(
        onTap: () => setState(() {
          selectedDate = d;
          controller.selectedDate.value = d;
        }),
        child: Container(
          width: 65,
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: sel ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat.E('fr_FR').format(d).toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: sel ? Colors.white : Colors.black)),
              SizedBox(height: 2),
              Text(DateFormat.d().format(d), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sel ? Colors.white : Colors.black)),
              Text(DateFormat.MMM('fr_FR').format(d).toUpperCase(), style: TextStyle(fontSize: 12, color: sel ? Colors.white : Colors.black)),
            ],
          ),
        ),
      );
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [...days]),
    );
  }

  // Time slot selector UI
  Widget buildTimeSlotSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Matin', 'Déjeuner', 'Dîner'].map((slot) {
        final sel = selectedTimeSlot == slot;
        return ChoiceChip(
          label: Text("$slot\n${timeRanges[slot]}", textAlign: TextAlign.center, style: TextStyle(color: sel ? Colors.white : Colors.black, fontSize: 12)),
          selected: sel,
          onSelected: (_) => setState(() {
            selectedTimeSlot = slot;
            selectedExactTime = null;
          }),
          selectedColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade400)),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        );
      }).toList(),
    );
  }

  // Exact time selector UI
  Widget buildExactTimeSelector() {
    final now = DateTime.now();
    return Center(
      child: Wrap(
        spacing: 8,
        children: getTimeOptions(selectedTimeSlot).map((time) {
          final parts = time.split(':');
          final dt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(parts[0]), int.parse(parts[1]));
          final isPast = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day && dt.isBefore(now);
          final sel = time == selectedExactTime;
          return ChoiceChip(
            label: Text(isPast ? "$time ❌" : "$time ⏰", style: TextStyle(color: sel ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
            selected: sel,
            onSelected: isPast ? null : (_) => setState(() {
              selectedExactTime = time;
              controller.selectedExactTime.value = time;
            }),
            selectedColor: Colors.black,
            backgroundColor: isPast ? Colors.grey[300] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey)),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Réserver une table", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
      body: SafeArea(
  child: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    physics: BouncingScrollPhysics(), // pour un scroll fluide
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                "http://10.0.2.2:3000/uploads/miams.jpg",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Miam's",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text("Choisissez une date", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        buildDateSelector(),
        SizedBox(height: 20),
        Text("Créneau horaire", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        buildTimeSlotSelector(),
        SizedBox(height: 20),
        Text("Sélectionnez une heure", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        buildExactTimeSelector(),
        SizedBox(height: 20),
        buildZone("Zone A – Vue sur mer", controller.tables.where((t) => t.view?.contains('mer') == true).toList()),
        buildZone("Zone B – Salle intérieure", controller.tables.where((t) => t.view?.contains('intérieure') == true).toList()),
        buildZone("Zone C – Jardin/Terrasse", controller.tables.where((t) => t.view?.contains('terrasse') == true).toList()),
        SizedBox(height: 30), // ← ← plus de marge pour scroll jusqu’au bouton
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // tu peux mettre ici le controller.confirmReservation() si tu veux
            },
            icon: Icon(Icons.check, color: Colors.white),
            label: Text("Compléter la réservation", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
          ),
        ),
        SizedBox(height: 70), // ← ← ça permet d’avoir de l’espace **en dessous du bouton**
      ],
    ),
  ),
),

    );
  }
}
