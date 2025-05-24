import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reservini/controllers/welcom_page_controller.dart';

class AllDishesPage extends StatelessWidget {
  final WelcomePageController controller = Get.find();
  final RxMap<String, int> selectedQuantities = <String, int>{}.obs;
  final RxString selectedRestaurant = ''.obs;
  final RxString selectedCategory = ''.obs;

  AllDishesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final plats = controller.popularPlats;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les plats", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Obx(() {
            final count = selectedQuantities.values.fold(0, (sum, q) => sum + q);
            return Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.black),
                  onPressed: () {
                    // Redirection panier
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    value: selectedRestaurant.value.isEmpty ? null : selectedRestaurant.value,
                    decoration: const InputDecoration(labelText: "Filtrer par restaurant"),
                    items: controller.restaurants.map<DropdownMenuItem<String>>((r) {
                      return DropdownMenuItem<String>(
                        value: r['name'],
                        child: Text(r['name']),
                      );
                    }).toList(),
                    onChanged: (value) => selectedRestaurant.value = value ?? '',
                  )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    value: selectedCategory.value.isEmpty ? null : selectedCategory.value,
                    decoration: const InputDecoration(labelText: "Type de plat"),
                    items: controller.categories.map<DropdownMenuItem<String>>((c) {
                      return DropdownMenuItem<String>(
                        value: c,
                        child: Text(c),
                      );
                    }).toList(),
                    onChanged: (value) => selectedCategory.value = value ?? '',
                  )),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredPlats = plats.where((plat) {
                final restMatch = selectedRestaurant.value.isEmpty ||
                    (plat['menu']?['restaurant']?['name'] ?? '') == selectedRestaurant.value;
                final catMatch = selectedCategory.value.isEmpty ||
                    (plat['type'] ?? '') == selectedCategory.value;
                return restMatch && catMatch;
              }).toList();

              if (filteredPlats.isEmpty) return const Center(child: Text("Aucun plat trouvé."));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPlats.length,
                itemBuilder: (context, index) {
                  final plat = filteredPlats[index];
                  final id = plat['id'].toString();
                  final name = plat['name'] ?? '';
                  final price = plat['price'] ?? 0;
                  final imageBase64 = plat['image'];
                  final restaurantName = plat['menu']?['restaurant']?['name'] ?? 'Restaurant inconnu';

                  Uint8List? imageBytes;
                  if (imageBase64 != null && imageBase64.isNotEmpty) {
                    try {
                      imageBytes = base64Decode(imageBase64.split(',').last);
                    } catch (_) {}
                  }

for (var plat in plats) {
  final id = plat['id'].toString();
  if (!selectedQuantities.containsKey(id)) {
    selectedQuantities[id] = 0;
  }
}

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        imageBytes != null
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.memory(imageBytes, height: 180, width: double.infinity, fit: BoxFit.cover),
                              )
                            : Container(
                                height: 180,
                                color: Colors.grey.shade300,
                                child: const Center(child: Icon(Icons.image_not_supported)),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("Prix : $price DT"),
                              Text("Restaurant : $restaurantName", style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 10),
                              Obx(() => Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Quantité :", style: TextStyle(fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: () {
                                              if (selectedQuantities[id]! > 0) {
                                                selectedQuantities[id] = selectedQuantities[id]! - 1;
                                              }
                                            },
                                          ),
                                          Text('${selectedQuantities[id]}',
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            onPressed: () {
                                              selectedQuantities[id] = selectedQuantities[id]! + 1;
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
