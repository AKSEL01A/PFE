  import 'dart:convert';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:get_storage/get_storage.dart';
  import 'package:http/http.dart' as http;
  import 'package:reservini/controllers/confirmation_reservation_controller.dart';
import 'package:reservini/controllers/history_controller.dart';
  import 'package:reservini/controllers/notifications_controller.dart'; // ✅ Ajout ici

  class TableReservationController extends GetxController {
    var tables = <TableModel>[].obs;
    var peopleCount = 1.obs;
    var chairsCount = 1.obs;
    var hasNote = false.obs;
    var noteText = ''.obs;
    var selectedDate = DateTime.now().obs;
    var selectedExactTime = ''.obs;
    var latestReservationId = ''.obs; // ✅ متغير لتخزين ID

    Future<void> fetchTables(String restaurantId) async {
      final box = GetStorage();
      final token = box.read('token');
      final HistoryController historyController = Get.put(HistoryController());

      if (token == null || token.isEmpty) {
        print("❌ Token manich mawjoud !");
        return;
      }

      print("🔁 Fetching tables for restaurant ID: $restaurantId");

      try {
        final response = await http.get(
          Uri.parse('https://restaurant-back-main.onrender.com/tables/restaurant/$restaurantId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print("📡 Response status: ${response.statusCode}");
        print("📡 Response body: ${response.body}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          print("✅ Tables reçues: ${data.length}");
          tables.value = data.map((e) => TableModel.fromJson(e)).toList();
        } else {
          print("❌ Failed to fetch tables: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ Erreur fetch tables : $e");
      }
    }

    bool isReservationComplete({
      required DateTime selectedDate,
      required String? selectedExactTime,
      required List<TableModel> selectedTables,
    }) {
      return selectedExactTime != null && selectedTables.isNotEmpty;
    }

    void resetReservationDetails() {
      peopleCount.value = 1;
      chairsCount.value = 1;
      hasNote.value = false;
      noteText.value = '';
    }

    Future<void> checkTableAvailability(String restaurantId) async {
      final box = GetStorage();
      final token = box.read('token');
      final date = selectedDate.value.toIso8601String().split('T')[0];
      final time = selectedExactTime.value;

      if (token == null || token.isEmpty || time.isEmpty) return;

      try {
        final response = await http.get(
          Uri.parse(
              'https://restaurant-back-main.onrender.com/reservations/availability?restaurantId=$restaurantId&date=$date&time=$time'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<String> reservedTableIds = List<String>.from(json.decode(response.body));
          for (var t in tables) {
            t.reserved = reservedTableIds.contains(t.id);
          }
          tables.refresh();
        } else {
          print('Erreur disponibilité: ${response.statusCode}');
        }
      } catch (e) {
        print('Erreur checkTableAvailability: $e');
      }
    }
Future<void> confirmReservation([VoidCallback? onSuccess]) async {
  print("⏳ Début de confirmReservation");
  final box = GetStorage();
  final token = box.read('token');
  print("🔑 Token: $token");

  if (token == null || token.isEmpty) {
    print("❌ Token manquant");
    return;
  }

  if (selectedExactTime.value.isEmpty) {
    print("❌ Heure vide");
    Get.snackbar("Erreur", "Veuillez choisir une heure exacte.");
    return;
  }

  final selectedTables = tables.where((t) => t.selected).toList();
  print("🪑 Tables sélectionnées: ${selectedTables.length}");

  if (selectedTables.isEmpty) {
    print("❌ Aucune table sélectionnée");
    Get.snackbar("Erreur", "Veuillez sélectionner une table.");
    return;
  }

  final selectedTable = selectedTables.first;

  if (selectedTable.reserved) {
    print("❌ Table déjà réservée");
    Get.snackbar("Indisponible", "Cette table est déjà réservée dans ce créneau.");
    return;
  }

  final userName = box.read('userName');
  final userPhone = box.read('userPhone');
  print("👤 Nom: $userName, Téléphone: $userPhone");

  if (userName == null || userPhone == null) {
    print("❌ Données utilisateur incomplètes");
    Get.snackbar("Erreur", "Les données de l'utilisateur sont incomplètes");
    return;
  }

  String mealType = getMealType(selectedExactTime.value);
  print("🍽️ Meal Type: $mealType");

  final reservationPayload = {
    'tableId': selectedTable.id,
    'customerName': userName,
    'phone': userPhone,
    'platIds': [],
    'reservationTime': {
      'name': mealType,
      'startTime': selectedExactTime.value,
      'endTime': addOneHour(selectedExactTime.value),
      'date2': selectedDate.value.toIso8601String().split('T')[0],
    },
  };

  print("📦 Payload de réservation: $reservationPayload");

  try {
    final reservationResponse = await http.post(
      Uri.parse('https://restaurant-back-main.onrender.com/reservations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(reservationPayload),
    );

    print("📡 Code réponse: ${reservationResponse.statusCode}");

    if (reservationResponse.statusCode == 201) {
      final responseBody = json.decode(reservationResponse.body);
      final reservationId = responseBody['id']; // ✅ définir correctement
      latestReservationId.value = reservationId; // ✅ assigner pour le QR code

      reservationPayload['id'] = reservationId;
      reservationPayload['date'] = reservationPayload['reservationTime']['date2'];
      reservationPayload['tables'] = selectedTable.name ?? '—';
      reservationPayload['chairsCount'] = selectedTable.numChaises;
      reservationPayload['selectedExactTime'] = selectedExactTime.value;

      print("✅ Réservation réussie, ID = $reservationId");

      final confirmationController = Get.find<ConfirmationReservationController>();
      confirmationController.fetchReservationsFromBackend();

      final historyController = Get.put(HistoryController(), permanent: true);
      historyController.addAction(
        'Réservation',
        'Table ${selectedTable.name ?? '—'} réservée pour le $mealType à ${selectedExactTime.value}'
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final notifCtrl = Get.find<NotificationsController>();
          notifCtrl.sendSuccessNotification(
            selectedTable.name ?? '—',
            selectedExactTime.value,
            mealType,
          );
          print("📢 Notification envoyée");
        } catch (e) {
          print("❌ Erreur lors de l'envoi de la notification: $e");
        }
      });

      if (onSuccess != null) {
        onSuccess(); // 👈 ça redirige vers la page de confirmation
      }
    } else {
      print('❌ Réponse erreur: ${reservationResponse.body}');
      Get.snackbar("Erreur", "Erreur lors de la réservation.");
    }

  } catch (e) {
    print("❌ Exception: $e");
    Get.snackbar("Erreur", "Une erreur est survenue lors de la réservation.");
  }
}




    String getMealType(String selectedTime) {
      final timeParts = selectedTime.split(':');
      if (timeParts.isNotEmpty) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        if (hour >= 6 && hour < 12) return 'matin';
        if (hour >= 12 && hour < 17) return 'déjeuner';
        return 'dîner';
      }
      return 'matin';
    }

    String addOneHour(String? time) {
      if (time == null || time.isEmpty || !time.contains(':')) {
        if (kDebugMode) print("❌ Heure invalide reçue dans addOneHour(): $time");
        return '';
      }

      final parts = time.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final newHour = (hour + 1) % 24;
      return '${newHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }


    Future<List<Map<String, dynamic>>> fetchMealTimes() async {
  final token = GetStorage().read('token');
  final response = await GetConnect().get(
    'https://restaurant-back-main.onrender.com/meal-times',
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(response.body);
  } else {
    Get.snackbar("Erreur", "Impossible de charger les horaires");
    return [];
  }
}

  }

  class TableModel {
    final String id;
    final String? name;
    final int numChaises;
    final String status;
    final String? view;
    final int? row, col;
    final String shape;
    bool selected;
    bool reserved;

    TableModel({
      required this.id,
      this.name,
      required this.numChaises,
      required this.status,
      this.view,
      this.row,
      this.col,
      required this.shape,
      this.selected = false,
      this.reserved = false,
    });

    factory TableModel.fromJson(Map<String, dynamic> json) => TableModel(
          id: json['id'],
          name: json['name'],
          numChaises: json['numChaises'],
          status: json['status'],
          view: json['view'],
          row: json['row'],
          col: json['col'],
          shape: json['shape'],
          reserved: json['reserved'] == true || json['status'] == 'réservé',
        );

    String get viewLabel {
      const viewLabels = {
        'SEA_VIEW': 'Vue sur mer',
        'INDOOR': 'Salle intérieure/bar',
        'TERRACE': 'Jardin/Terrasse',
      };

      if (view == null) return '—';
      if (viewLabels.containsKey(view)) return viewLabels[view]!;
      return view!;
    }
  }
