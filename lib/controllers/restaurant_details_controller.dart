import 'package:get/get.dart';
class RestaurantDetailsController extends GetxController {
  final Map<String, dynamic> restaurant;

  RestaurantDetailsController(this.restaurant);

  String? get imageUrl {
    final images = restaurant['images'];
    if (images != null &&
        images is List &&
        images.isNotEmpty &&
        images[0]['url'] != null) {
      return 'https://restaurant-back-main.onrender.com/uploads/${images[0]['url']}';
    }
    return null;
  }

  String get name => restaurant['name'] ?? '';
  String get address => restaurant['address'] ?? '';
  String get openingHours => restaurant['openingHours'] ?? 'Non spécifié';
  String get phone => restaurant['phone'] ?? '';
  String get categorie => restaurant['categorie'] ?? '';
  String get description => restaurant['description'] ?? '';
}
