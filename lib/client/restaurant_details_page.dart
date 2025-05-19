import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reservini/controllers/restaurant_details_controller.dart';
import 'package:reservini/client/reservation_page.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  Future<void> _callRestaurant(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text("Impossible de lancer l’appel")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = RestaurantDetailsController(restaurant);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(controller.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  controller.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            Text("📍 ${controller.address}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 248, 248, 248),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "🕒 Horaires d’ouverture",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        controller.openingHours,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    ],
  ),
),

            const SizedBox(height: 8),
            Text("📞 ${controller.phone}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("🍽️ ${controller.categorie}", style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 16),
Text("📝 Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 6),
Text(
  controller.description,
  style: const TextStyle(fontSize: 15, color: Colors.black87),
),

            // Boutons côte à côte
// Ancienne Row supprimée
            const SizedBox(height: 24),

// Bouton Appeler
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      _callRestaurant(controller.phone);
    },
    icon: const Icon(Icons.call),
    label: const Text("Appeler le restaurant"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    ),
  ),
),
const SizedBox(height: 12),

// Bouton Réserver
SizedBox(
  width: double.infinity, 
  child: ElevatedButton.icon(
    onPressed: () {
      Get.to(() => TableReservationPage(restaurant: restaurant));
    },
    icon: const Icon(Icons.restaurant),
    label: const Text("Réserver maintenant"),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    ),
  ),
),


          ],
        ),
      ),
    );
  }
}
