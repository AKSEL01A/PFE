import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reservini/client/all_dishes_page.dart';
import 'package:reservini/client/reservation_page.dart';
import 'package:reservini/client/restaurant_details_page.dart';
import 'package:reservini/controllers/notifications_controller.dart';
import 'package:reservini/controllers/profile_controller.dart';
import 'package:reservini/controllers/welcom_page_controller.dart';

class WelcomePageClient extends StatefulWidget {
  const WelcomePageClient({Key? key}) : super(key: key);

  @override
  State<WelcomePageClient> createState() => _WelcomePageClientState();
}

class _WelcomePageClientState extends State<WelcomePageClient> {
  late final WelcomePageController controller;
  final ProfileController profileController = Get.put(ProfileController());
  late final PageController _pageController;
  final NotificationsController notificationsController = Get.put(NotificationsController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(WelcomePageController());
    _pageController = PageController(viewportFraction: 1);
  }

  List<dynamic> get restaurants => Get.find<WelcomePageController>().restaurants;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Photo de profil + Bienvenue
              Row(
                children: [
                  Obx(() {
                    final imagePath = profileController.imagePath.value;
                    return CircleAvatar(
                      radius: 30,
                      backgroundImage: imagePath != null
                          ? FileImage(File(imagePath))
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: imagePath == null
                          ? const Icon(Icons.person, color: Colors.black, size: 30)
                          : null,
                    );
                  }),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                              "Bienvenue, ${profileController.userName.value}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        Obx(() => Text(
                              profileController.userEmail.value,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
              final city = controller.userCity.value;
                return city.isNotEmpty
                    ? Text(
                        city,
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      )
                    : const SizedBox.shrink();
              }),


              const SizedBox(height: 16),

              // Barre de recherche
              TextField(
                onChanged: (value) {
                  controller.updateSearch(value);
                  controller.isAutoScrollEnabled.value = false;
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "Rechercher un restaurant...",
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: controller.filterNearbyRestaurants,
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text("À proximité",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Trouvez votre endroit préféré 🍽️",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Filtres cuisines
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  final filters = ["Tous", "Italien", "Tunisien", "Japonais", "Français"];
                  final emojis = {
                    "Italien": "🍕",
                    "Tunisien": "🫖",
                    "Japonais": "🍣",
                    "Français": "🥖",
                    "Tous": "🍽️",
                  };

                  return Row(
                    children: filters.map((filter) {
                      final isSelected =
                          controller.selectedCuisine.value == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            "${emojis[filter]} $filter",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => controller.selectCuisine(filter),
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),

              const SizedBox(height: 24),

              const Text(
                "Suggestions par catégorie 🍽️",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  final categories = ["Tous", "Pizza", "Sushi", "Healthy", "Couscous"];
                  final emojis = {
                    "Tous": "🍽️",
                    "Pizza": "🍕",
                    "Sushi": "🍣",
                    "Healthy": "🥗",
                    "Couscous": "🫖",
                  };

                  return Row(
                    children: categories.map((cat) {
                      final isSelected =
                          controller.selectedCategory.value == cat;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text("${emojis[cat]} $cat"),
                          selected: isSelected,
                          onSelected: (_) {
                            if (cat == "Tous") {
                              controller.selectedCategory.value = "";
                            } else {
                              controller.selectCategory(cat);
                            }
                            controller.applyFilters();
                          },
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),

              const SizedBox(height: 24),

              const Text(
                "Découvrez nos restaurants et plats du jour 🍽️🔥",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 16),

              if (restaurants.isEmpty)
                const Center(child: Text("Aucun restaurant trouvé."))
              else
                SizedBox(
                  height: 450,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index % restaurants.length];
                      final List<dynamic> images = restaurant['images'] ?? [];
                      final imageUrl = images.isNotEmpty
                          ? 'https://restaurant-back-main.onrender.com/uploads/${images[0]['url']}'
                          : 'https://restaurant-back-main.onrender.com/uploads/placeholder.jpg';
                      final rating =
                          double.tryParse(restaurant['note']?.toString() ?? '0') ?? 0;

                      return RestaurantCard(
                        restaurant: restaurant,
                        imageUrl: imageUrl,
                        rating: rating,
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              

              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
                "⭐ Plats les plus populaires",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
    TextButton(
      onPressed: () {
        Get.to(() => AllDishesPage());
      },
      child: const Text(
        "Voir tout",
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    ),
  ],
),
const SizedBox(height: 16),

              const SizedBox(height: 12),

              Obx(() {
                final plats = controller.popularPlats;
                if (plats.isEmpty) {
                  return const Text("Aucun plat trouvé.");
                }
                return PopularDishesList(plats: plats);
              }),

              const SizedBox(height: 24),

             const Text(
  "⏰ Notifications de réservation",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
),
const SizedBox(height: 12),

Obx(() {
  final notifications = notificationsController.notifications;
  if (notifications.isEmpty) {
    return const Text("Aucune notification récente.");
  }

  return Column(
    children: notifications.take(3).map((notif) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (notif['color'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notif['color']),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(notif['icon'], color: notif['color'], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(notif['description']),
                  const SizedBox(height: 4),
                  Text(notif['time'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}),

            ],
          ),
        );
      }),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  const CategoryChip({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
// À compléter : RestaurantCard & PopularDishesList si tu veux que je te les écrive proprement aussi




class RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final String imageUrl; // مش مستعملة توا، نجم تنحيها
  final double rating;

  const RestaurantCard({
    required this.restaurant,
    required this.imageUrl,
    required this.rating,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? base64String = restaurant['images']?[0]?['url'];
    Uint8List? imageBytes;

    if (base64String != null && base64String.isNotEmpty) {
      try {
        final String pureBase64 = base64String.contains(',')
            ? base64String.split(',').last
            : base64String;
        imageBytes = base64Decode(pureBase64);
      } catch (e) {
        print("Erreur décodage image base64: $e");
      }
    }

    Widget imageWidget;
    if (imageBytes != null) {
      imageWidget = Image.memory(
        imageBytes,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    } else {
      imageWidget = Container(
        height: 240,
        width: double.infinity,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_not_supported),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageWidget,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      restaurant['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (star) {
                  return Icon(
                    Icons.star,
                    size: 20,
                    color:
                        star < rating ? Colors.amber : Colors.grey.shade300,
                  );
                }),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
  onPressed: () {
    final raw = restaurant['images']?[0]?['url'];
    final fullUrl = raw != null && !raw.startsWith('http')
        ? 'https://restaurant-back-main.onrender.com/uploads/$raw'
        : raw ?? 'https://restaurant-back-main.onrender.com/uploads/placeholder.jpg';

    Get.to(() => TableReservationPage(
      restaurant: {
        ...restaurant,
        'imageUrl': fullUrl, // ✅ ENVOIE UNE VRAIE URL
      },
    ));
  },
  icon: const Icon(Icons.event_seat, color: Colors.white),
  label: const Text("Réserver", style: TextStyle(color: Colors.white)),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    minimumSize: const Size.fromHeight(45),
  ),
),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => RestaurantDetailsPage(restaurant: restaurant));
                },
                icon: const Icon(Icons.info_outline, color: Colors.black),
                label: const Text("Explorer",
                    style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size.fromHeight(45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PopularDishesList extends StatelessWidget {
  final List<dynamic> plats;

  const PopularDishesList({required this.plats, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1),
        itemCount: plats.length,
        itemBuilder: (context, index) {
          final plat = plats[index];

          // 🧠 Récupérer l'image base64
          final String? base64String = plat['image']; // ou ['images'][0]['url'] si t'as une liste
          Uint8List? imageBytes;

          if (base64String != null && base64String.isNotEmpty) {
            try {
              final pureBase64 = base64String.contains(',')
                  ? base64String.split(',').last
                  : base64String;
              imageBytes = base64Decode(pureBase64);
            } catch (e) {
              print("Erreur de décodage base64 (plat): $e");
            }
          }

          Widget imageWidget;
          if (imageBytes != null) {
            imageWidget = Image.memory(
              imageBytes,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            );
          } else {
            imageWidget = Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageWidget,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => PlatDetailsDialog(
                                  plat: plat,
                                  imageUrl: base64String ?? '',
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(200, 255, 255, 255),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove_red_eye, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Action commander ici
                      },
                      icon: const Icon(Icons.shopping_cart,
                          color: Colors.white, size: 16),
                      label: const Text("Commander",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(screenWidth, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlatDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> plat;
  final String imageUrl; // base64 string

  const PlatDetailsDialog({
    required this.plat,
    required this.imageUrl,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;

    if (imageUrl.isNotEmpty) {
      try {
        final pureBase64 = imageUrl.contains(',')
            ? imageUrl.split(',').last
            : imageUrl;
        imageBytes = base64Decode(pureBase64);
      } catch (e) {
        print("Erreur de décodage image plat: $e");
      }
    }

    Widget imageWidget;
    if (imageBytes != null) {
      imageWidget = Image.memory(
        imageBytes,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    } else {
      imageWidget = Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_not_supported),
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageWidget,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    plat['name'] ?? 'Plat',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Type : ${plat['type'] ?? '---'}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Prix : ${plat['price'] ?? '--'} DT",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    plat['description'] ?? 'Aucune description disponible.',
                    style:
                        const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}
