// lib/pages/table_reservation_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reservini/client/reservation_confirmation_page.dart';
import 'package:reservini/controllers/table_reservation_controller.dart';

class TableReservationPage extends StatefulWidget {
  final Map<String, dynamic> restaurant; // <-- Ajouter ça

  TableReservationPage({required this.restaurant}); // <-- Modifier le constructeur

  @override
  _TableReservationPageState createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  late final TableReservationController controller;

  late String restaurantName;
late String restaurantImageUrl;



  DateTime selectedDate = DateTime.now().add(Duration(days: 1));
  String? selectedExactTime;
  String selectedTimeSlot = 'Déjeuner';
  int selectedChairs = 2;
  

  static const _viewLabels = {
    'SEA_VIEW'   : 'Vue sur mer',
    'INDOOR'     : 'Salle intérieure',
    'TERRACE'    : 'Jardin/Terrasse',
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    controller = Get.put(TableReservationController());
    controller.selectedDate.value = selectedDate;
    restaurantName = widget.restaurant['name'] ?? 'Restaurant';
    restaurantImageUrl = widget.restaurant['image'] ?? 'http://10.0.2.2:3000/uploads/default.jpg';
    controller.fetchTables(widget.restaurant['id']);
  }

  List<String> getTimeOptions(String slot) {
    switch (slot) {
      case 'Matin':   return ['08:00','09:00','10:00','11:00'];
      case 'Déjeuner':return ['12:00','13:00','14:00','15:00','16:00','17:00'];
      case 'Dîner':   return ['18:00','19:00','20:00','21:00','22:00','23:00'];
      default:        return [];
    }
  }

  final Map<String,String> timeRanges = {
    'Matin'  : '08:00 - 12:00',
    'Déjeuner': '12:00 - 18:00',
    'Dîner'  : '18:00 - 00:00',
  };

  void toggleSelection(TableModel t) {
    setState(() => t.selected = !t.selected);
    controller.tables.refresh();
  }

  Widget buildTable(TableModel t) {
    final isSel = t.selected;
    final label = t.name ?? t.id.substring(0,4);
    return GestureDetector(
      onTap: () => toggleSelection(t),
      child: Container(
        width: 50, height: 50,
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
  color: t.reserved
      ? Colors.red[300]
      : isSel
          ? Colors.green
          : Colors.white,
  border: Border.all(color: Colors.grey.shade400, width: 1.5),
  borderRadius: BorderRadius.circular(8),
),

        child: Center(child: Text(label,
          style: TextStyle(
            color: isSel ? Colors.white : Colors.black,
            fontSize: 11, fontWeight: FontWeight.bold,
          ),
        )),
      ),
    );
  }

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


  Widget buildDateSelector() {
  final days = List.generate(7, (i) {
    final d = DateTime.now().add(Duration(days: i));
    final sel = d.year == selectedDate.year &&
        d.month == selectedDate.month &&
        d.day == selectedDate.day;

    return GestureDetector(
      onTap: () => setState(() {
        selectedDate = d;
        controller.selectedDate.value = d; // 🔥 Mise à jour du controller
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
            Text(
              DateFormat.E('fr_FR').format(d).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: sel ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 2),
            Text(
              DateFormat.d().format(d),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sel ? Colors.white : Colors.black,
              ),
            ),
            Text(
              DateFormat.MMM('fr_FR').format(d).toUpperCase(),
              style: TextStyle(
                  fontSize: 12, color: sel ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  });

  final cal = GestureDetector(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        ),
      );
      if (d != null) {
        setState(() {
          selectedDate = d;
          controller.selectedDate.value = d; // 🔥 Mise à jour du controller
        });
      }
    },
    child: Container(
      width: 65,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 20),
          SizedBox(height: 6),
          Text('Autre', style: TextStyle(fontSize: 12)),
          Text('Date', style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: [...days, cal]),
  );
}

  Widget buildTimeSlotSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Matin','Déjeuner','Dîner'].map((slot){
        final sel = selectedTimeSlot==slot;
        return ChoiceChip(
          label: Text("$slot\n${timeRanges[slot]}",
            textAlign: TextAlign.center,
            style: TextStyle(color: sel ? Colors.white : Colors.black, fontSize:12),
          ),
          selected: sel,
          onSelected: (_) => setState((){
            selectedTimeSlot = slot;
            selectedExactTime = null;
          }),
          selectedColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade400),
          ),
          padding: EdgeInsets.symmetric(horizontal:8,vertical:6),
        );
      }).toList(),
    );
  }

  Widget buildExactTimeSelector() {
  final now = DateTime.now();
  return Center(
    child: Wrap(
      spacing: 8,
      children: getTimeOptions(selectedTimeSlot).map((time) {
        final parts = time.split(':');
        final dt = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        final isPast = selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day &&
            dt.isBefore(now);

        final sel = time == selectedExactTime;

        return ChoiceChip(
          label: Text(
            isPast ? "$time ❌" : "$time ⏰",
            style: TextStyle(
              color: sel ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: sel,
          onSelected: isPast
              ? null
              : (_) async {
                  setState(() {
                    selectedExactTime = time;
                    controller.selectedExactTime.value = time;
                  });

                  // 🟢 Appeler la fonction de vérification de disponibilité
                  await controller.checkTableAvailability(widget.restaurant['id']);
                },
          selectedColor: Colors.black,
          backgroundColor: isPast ? Colors.grey[300] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey),
          ),
        );
      }).toList(),
    ),
  );
}


void openReservationDialog() {
  final selectedTables = controller.tables.where((t) => t.selected).toList();

  final ok = controller.isReservationComplete(
    selectedDate: selectedDate,
    selectedExactTime: selectedExactTime,
    selectedTables: selectedTables,
  );

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("⚠️ Veuillez remplir tous les champs : date, heure et table.")),
    );
    return;
  }

  controller.resetReservationDetails();
  controller.chairsCount.value = selectedChairs;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      title: Center(
        child: Text(
          "Compléter la réservation",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📅 Date :", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(DateFormat.yMMMMd('fr_FR').format(selectedDate)),
            SizedBox(height: 16),

            Text("🕓 Heure exacte :", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text("$selectedTimeSlot à ${selectedExactTime ?? ''}"),
            SizedBox(height: 16),

            Text("🍽️ Tables sélectionnées :", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(selectedTables.map((t) =>
              t.viewLabel + (t.name != null ? " ${t.name}" : " ${t.id.substring(0, 4)}")
            ).join(', ')),
            SizedBox(height: 16),

            Obx(() => buildCountRow(
              label: "👥 Nombre de personnes :",
              value: controller.peopleCount.value,
              onDecrement: () => controller.peopleCount.value = max(1, controller.peopleCount.value - 1),
              onIncrement: () => controller.peopleCount.value++,
              onChanged: (v) => controller.peopleCount.value = int.tryParse(v) ?? 1,
            )),
            SizedBox(height: 16),

            Obx(() => buildCountRow(
              label: "🪑 Nombre de chaises :",
              value: controller.chairsCount.value,
              onDecrement: () => controller.chairsCount.value = max(1, controller.chairsCount.value - 1),
              onIncrement: () => controller.chairsCount.value++,
              onChanged: (v) => controller.chairsCount.value = int.tryParse(v) ?? 1,
            )),
            SizedBox(height: 16),

            Text("✍️ Ajouter une note ?", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Obx(() => buildNoteOptions(controller)),
            Obx(() => AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: controller.hasNote.value
                ? Padding(
                    key: ValueKey('note'),
                    padding: EdgeInsets.only(top: 12),
                    child: TextField(
                      maxLines: 3,
                      onChanged: (v) => controller.noteText.value = v,
                      decoration: InputDecoration(
                        hintText: "Entrez votre note ici...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(key: ValueKey('noNote')),
            )),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Annuler"),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            if (controller.hasNote.value && controller.noteText.value.trim().isEmpty) {
              Get.snackbar(
                "Note manquante",
                "Veuillez écrire une note ou choisir 'Non'.",
                backgroundColor: Colors.orange[100],
                colorText: Colors.black,
              );
              return;
            }

            controller.confirmReservation(() {
              Navigator.pop(context);
              Get.to(() => ReservationConfirmationPage(
                reservationDetails: {
                  'date': DateFormat.yMMMMd('fr_FR').format(selectedDate),
                  'timeSlot': '$selectedTimeSlot à ${selectedExactTime ?? ''}',
                  'tables': selectedTables.map((t) =>
                    t.viewLabel + (t.name != null ? " ${t.name}" : " ${t.id.substring(0, 4)}")
                  ).join(', '),
                  'peopleCount': controller.peopleCount.value,
                  'chairsCount': controller.chairsCount.value,
                  'note': controller.noteText.value.isNotEmpty
                      ? controller.noteText.value
                      : 'Aucune note',
                },
              ));
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: Text("Confirmer"),
        ),
      ],
    ),
  );
}


  Widget buildCountRow({
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required ValueChanged<String> onChanged,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children:[
      Expanded(flex:2, child:Text(label,style:TextStyle(fontWeight:FontWeight.bold))),
      Row(children:[
        IconButton(icon:Icon(Icons.remove),onPressed:onDecrement),
        SizedBox(
          width:50,
          child: TextField(
            textAlign:TextAlign.center,
            controller: TextEditingController(text:value.toString()),
            keyboardType: TextInputType.number,
            onChanged:onChanged,
            decoration: InputDecoration(border: OutlineInputBorder(), isDense:true, contentPadding:EdgeInsets.symmetric(vertical:10)),
          ),
        ),
        IconButton(icon:Icon(Icons.add),onPressed:onIncrement),
      ]),
    ],
  );

  Widget buildNoteOptions(TableReservationController c) => Row(
    children:[
      GestureDetector(
        onTap: ()=>c.hasNote.value=true,
        child: Container(
          padding:EdgeInsets.symmetric(horizontal:16,vertical:10),
          decoration:BoxDecoration(
            color: c.hasNote.value?Colors.black:Colors.grey[200],
            borderRadius:BorderRadius.circular(10),
            border:Border.all(color:Colors.black),
          ),
          child:Text("Oui",style:TextStyle(color:c.hasNote.value?Colors.white:Colors.black)),
        ),
      ),
      SizedBox(width:12),
      GestureDetector(
        onTap: ()=>c.hasNote.value=false,
        child: Container(
          padding:EdgeInsets.symmetric(horizontal:16,vertical:10),
          decoration:BoxDecoration(
            color: !c.hasNote.value?Colors.black:Colors.grey[200],
            borderRadius:BorderRadius.circular(10),
            border:Border.all(color:Colors.black),
          ),
          child:Text("Non",style:TextStyle(color:!c.hasNote.value?Colors.white:Colors.black)),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final all = controller.tables;
final zoneA = all.where((t) =>
  t.view == 'mer' || t.view == 'Près de la fenêtre'
).toList();

final zoneB = all.where((t) =>
  t.view == 'Près du bar'
).toList();

final zoneC = all.where((t) =>
  t.view == 'classique'
).toList();




    return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    title: Text("Réserver une table", style: TextStyle(color: Colors.black)),
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
  ),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📸 Image avec nom au centre
        Stack(
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        restaurantImageUrl,
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
              restaurantName,            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  ],
),

        SizedBox(height: 20),

        // 🗓️ Choix de la date
        Text("Choisissez une date", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10), buildDateSelector(),
        SizedBox(height: 20), Text("Créneau horaire", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10), buildTimeSlotSelector(),
        SizedBox(height: 20), Text("Heure d'arrivée prévue", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10), buildExactTimeSelector(),
        SizedBox(height: 20),

        // 🪑 Zones de tables
        buildZone("Zone A – Vue sur mer", zoneA),
        buildZone("Zone B – Salle intérieure", zoneB),
        buildZone("Zone C – Jardin/Terrasse", zoneC),
        SizedBox(height: 20),

        // ✅ Bouton de confirmation
        Center(
          child: ElevatedButton.icon(
            onPressed: openReservationDialog,
            icon: Icon(Icons.check, color: Colors.white),
            label: Text("Compléter la réservation", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            ),
          ),
        ),
      ],
    ),
  ),
);

  }
}
