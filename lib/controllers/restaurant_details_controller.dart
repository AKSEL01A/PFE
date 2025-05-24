import 'package:get/get.dart';

class RestaurantDetailsController extends GetxController {
  final Map<String, dynamic> restaurant;

  RestaurantDetailsController(this.restaurant);

  String get name => restaurant['name'] ?? '';
  String get address => restaurant['address'] ?? '';
  String get phone => restaurant['phone'] ?? '';
  String get categorie => restaurant['categorie'] ?? '';
  String get description => restaurant['description'] ?? '';

  // ⏰ Horaire : champ complet
  String get rawHourly => restaurant['hourly'] ?? '';

  // 🕗 Début (08:00)
  String get openTime {
    final parts = rawHourly.split('-');
    return parts.isNotEmpty ? parts[0].trim() : '';
  }

  // 🕙 Fin (22:00)
  String get closeTime {
    final parts = rawHourly.split('-');
    return parts.length > 1 ? parts[1].trim() : '';
  }
}
