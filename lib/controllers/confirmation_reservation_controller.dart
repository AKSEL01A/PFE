import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:reservini/controllers/notifications_controller.dart';

class ConfirmationReservationController extends GetxController {
  var reservations = <Map<String, dynamic>>[].obs;
  var restaurants = [].obs;
  var tables = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReservationsFromBackend();
  }

 Future<void> fetchRestaurants() async {
  final token = GetStorage().read('token');
  try {
    final response = await GetConnect().get(
      'https://restaurant-back-main.onrender.com/restaurant/restaurant', // ✅ الصحيح
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 && response.body != null) {
      restaurants.value = response.body;
    } else {
      print("❌ Erreur chargement restaurants: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Exception fetchRestaurants: $e");
  }
}

// À ajouter dans ConfirmationReservationController

Future<bool> checkAndUpdateReservation({
  required String reservationId,
  required String restaurantId,
  required String tableId,
  required String time,
  required String date,
}) async {
  final token = GetStorage().read('token');

  try {
    print("📅 Date utilisée: $date");
    print("⏰ Heure utilisée: $time");
    print("🍽️ Restaurant ID: $restaurantId");
    print("🪑 Table ID: $tableId");
    print("🆔 Reservation ID: $reservationId");

    final availabilityUrl = Uri.parse(
      'https://restaurant-back-main.onrender.com/reservations/availability'
      '?restaurantId=$restaurantId&date=$date&time=$time&reservationId=$reservationId',
    );

    final availabilityRes = await http.get(
      availabilityUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📶 Availability status: ${availabilityRes.statusCode}");
    print("📶 Availability body: ${availabilityRes.body}");

    if (availabilityRes.statusCode == 200) {
      final reservedIds = List<String>.from(jsonDecode(availabilityRes.body));
      if (reservedIds.contains(tableId)) {
        Get.snackbar("Indisponible", "La table est déjà réservée à cette heure");
        return false;
      }

      final updateUrl = Uri.parse(
        'https://restaurant-back-main.onrender.com/reservations/$reservationId',
      );

      final body = {
        "tableId": tableId,
        "reservationTime": {
          "startTime": time,
          "date2": date,
          "name": "AutoUpdate", // 🔑 requis côté backend DTO
        }
      };

      print("🔎 BODY envoyé au PATCH : ${jsonEncode(body)}");

      final patchRes = await http.patch(
        updateUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("✅ PATCH status: ${patchRes.statusCode}");
      print("✅ PATCH body: ${patchRes.body}");

      if (patchRes.statusCode.toString().startsWith("2")) {
        Get.snackbar("Succès ✅", "Réservation modifiée avec succès");
        await fetchReservationsFromBackend();
        Get.back();
        return true;
      } else {
        Get.snackbar("Erreur", "Échec de modification (${patchRes.statusCode})");
        return false;
      }
    } else {
      Get.snackbar("Erreur", "Échec vérification de disponibilité (${availabilityRes.statusCode})");
      return false;
    }
  } catch (e) {
    print("❌ Exception durant update: $e");
    Get.snackbar("Erreur", "Une erreur est survenue");
    return false;
  }
}

  Future<void> checkTableAvailability(String restaurantId, String date, String time) async {
  final token = GetStorage().read('token');

  print("🔍 Checking availability with:");
  print("🗓️ Date: $date");
  print("⏰ Time: $time");
  print("🍴 Restaurant ID: $restaurantId");

  if (token == null || token.isEmpty || time.isEmpty) return;

  try {
    final response = await http.get(
      Uri.parse('https://restaurant-back-main.onrender.com/reservations/availability?restaurantId=$restaurantId&date=$date&time=$time'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📡 Availability API status: ${response.statusCode}");
    print("📡 Body: ${response.body}");

    if (response.statusCode == 200) {
      final List<String> reservedTableIds = List<String>.from(json.decode(response.body));
      for (var t in tables) {
        t.reserved = reservedTableIds.contains(t.id);
      }
      tables.refresh();
    } else {
      print('❌ Erreur disponibilité: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erreur checkTableAvailability: $e');
  }
}


  Future<void> fetchTables(String restaurantId) async {
    final token = GetStorage().read('token');
    try {
      final response = await GetConnect().get(
        'https://restaurant-back-main.onrender.com/tables/restaurant/$restaurantId',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && response.body != null) {
        tables.value = response.body;
      } else {
        print("❌ Erreur chargement tables: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception fetchTables: $e");
    }
  }

  Future<void> fetchReservationsFromBackend() async {
    try {
      final token = GetStorage().read('token');
      final userId = GetStorage().read('userId');
      print('🔐 TOKEN utilisé : $token');
      print('👤 USER ID : $userId');

      final response = await GetConnect().get(
        'https://restaurant-back-main.onrender.com/reservations',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📦 Réponse brute : ${response.body}");

      if (response.statusCode == 200) {
        final allReservations = List<Map<String, dynamic>>.from(response.body);

        final userReservations = allReservations.where((res) {
          final user = res['user'];
          return user != null && user['id'].toString() == userId.toString();
        }).toList();

        for (var res in userReservations) {
          final table = res['table'];
          final restaurant = table?['restaurantBloc']?['restaurant'];
          res['restaurantName'] = restaurant?['name'] ?? 'Restaurant inconnu';
        }

        reservations.value = userReservations;
        print("✅ Réservations utilisateur : ${reservations.length}");
      } else {
        print("[ERROR] ${response.statusCode}");
        Get.snackbar("Erreur", "Impossible de charger les réservations");
      }
    } catch (e) {
      print("[EXCEPTION] $e");
      Get.snackbar("Erreur", "Erreur réseau lors du chargement");
    }
  }

  Future<void> markReservationAsCancelled(Map<String, dynamic> reservation) async {
  try {
    final String? id = reservation['id'];
    if (id == null) {
      throw "ID de réservation introuvable.";
    }

    final token = GetStorage().read('token');
    print("🔐 TOKEN utilisé pour annulation : $token");
    print("🆔 ID réservation : $id");

    final response = await GetConnect().patch(
      'https://restaurant-back-main.onrender.com/reservations/$id',
      {
        "isCancelled": true,
        "status": "cancelled", // Vérifie casse dans enum
      },
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📡 PATCH status: ${response.statusCode}");
    print("📦 PATCH body: ${response.body}");

    if (response.statusCode == 200) {
      reservation['status'] = 'cancelled';
      reservation['isCancelled'] = true;
      reservations.refresh();

      final notifCtrl = Get.find<NotificationsController>();
      notifCtrl.sendCancelNotification(reservation['customerName'] ?? "client");

      Get.snackbar("Succès ✅", "Réservation annulée avec succès");
    } else {
      Get.snackbar("Erreur ❌", "Échec de l’annulation (${response.statusCode})");
    }
  } catch (e) {
    print("❌ Exception annulation: $e");
    Get.snackbar("Erreur", "Une erreur est survenue : $e");
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

  bool canCancel(Map<String, dynamic> reservation) {
    try {
      final details = reservation['details'];
      final dateStr = details['date'];
      final timeStr = details['selectedExactTime'];
      if (dateStr == null || timeStr == null) return false;

      final isoDate = convertFrenchDateToIso(dateStr);
      if (isoDate == null) return false;

      final fullDateTime = DateTime.parse("$isoDate $timeStr:00");
      return fullDateTime.difference(DateTime.now()).inHours >= 2;
    } catch (_) {
      return false;
    }
  }
}
