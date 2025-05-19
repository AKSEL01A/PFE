import 'dart:convert';
import 'package:get/get.dart';
import 'package:reservini/controllers/notifications_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmationReservationController extends GetxController {
  var reservations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReservationsFromStorage();
  }

  void addReservation(Map<String, dynamic> reservationDetails) {
  final newReservation = {
    'id': reservationDetails['id'], // ✅ ID backend réel
    'name': 'Réservation #${reservationDetails['id']}', // 🔁 استعمل ID الحقيقي في l'affichage
    'date': reservationDetails['date'],
    'tables': reservationDetails['tables'],
    'chairs': reservationDetails['chairsCount'],
    'status': 'Validé',
    'details': reservationDetails,
    'qrData': jsonEncode(reservationDetails),
  };

  reservations.add(newReservation);
  saveReservationsToStorage();
}


  void cancelReservation(Map<String, dynamic> reservation) {
    reservations.remove(reservation);
    saveReservationsToStorage();
  }



  Future<void> markReservationAsCancelled(Map<String, dynamic> reservation) async {
  try {
    final id = reservation['id'];
    print("[INFO] Tentative d’annulation pour la réservation ID: $id");

    if (id != null) {
      final response = await GetConnect().patch(
        'https://restaurant-back-main.onrender.com/reservations/$id',
        {"isCancelled": true}
      );

      print("[INFO] Code réponse du serveur: ${response.statusCode}");

      if (response.statusCode == 200) {
        reservation['status'] = 'Annulé';
        reservations.refresh();
        await saveReservationsToStorage();

        print("[SUCCESS] Statut mis à jour localement pour la réservation: ${reservation['name']}");
        final notifCtrl = Get.find<NotificationsController>();
        notifCtrl.sendCancelNotification(reservation['name']);

        print("[NOTIFICATION] Notification d’annulation envoyée.");
        Get.snackbar("Annulé", "Réservation annulée avec succès");
      } else {
        print("[ERROR] Échec de l’annulation côté serveur. Code: ${response.statusCode}");
        Get.snackbar("Erreur", "Échec de l’annulation côté serveur.");
      }
    } else {
      print("[ERROR] ID introuvable dans la réservation");
      Get.snackbar("Erreur", "ID de réservation introuvable.");
    }
  } catch (e) {
    print("[EXCEPTION] Une erreur est survenue: $e");
    Get.snackbar("Erreur", "Une erreur est survenue : $e");
  }
}

  /// ✅ Appel backend pour DELETE + suppression locale
  Future<void> cancelReservationBackend(Map<String, dynamic> reservation) async {
    try {
      final id = reservation['id'];
      if (id != null) {
        final response = await GetConnect().delete(
          'https://restaurant-back-main.onrender.com/reservations/$id'
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          cancelReservation(reservation); // suppression locale
          final notifCtrl = Get.find<NotificationsController>();
          notifCtrl.sendCancelNotification(reservation['name']);
          Get.snackbar("Annulé", "Réservation annulée avec succès");
        } else {
          Get.snackbar("Erreur", "Échec de la suppression côté serveur.");
        }
      } else {
        Get.snackbar("Erreur", "ID de réservation introuvable.");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Une erreur est survenue : $e");
    }
  }

  Future<void> saveReservationsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonList = jsonEncode(reservations);
    await prefs.setString('userReservations', jsonList);
  }

  Future<void> loadReservationsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonList = prefs.getString('userReservations');
    if (jsonList != null) {
      final List decoded = jsonDecode(jsonList);
      reservations.value = decoded.cast<Map<String, dynamic>>();
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
      final now = DateTime.now();
      final difference = fullDateTime.difference(now);

      return difference.inHours >= 2;
    } catch (_) {
      return false;
    }
  }

  String? convertFrenchDateToIso(String frenchDate) {
    final mois = {
      'janvier': '01',
      'février': '02',
      'mars': '03',
      'avril': '04',
      'mai': '05',
      'juin': '06',
      'juillet': '07',
      'août': '08',
      'septembre': '09',
      'octobre': '10',
      'novembre': '11',
      'décembre': '12'
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
}
