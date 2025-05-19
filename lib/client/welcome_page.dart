import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reservini/client/reservation_page.dart';
import 'package:reservini/client/reservation_page.dart';
import 'package:reservini/client/restaurant_details_page.dart';
import 'package:reservini/controllers/welcom_page_controller.dart';

class WelcomePageClient extends StatefulWidget {
  const WelcomePageClient({Key? key}) : super(key: key);

  @override
  State<WelcomePageClient> createState() => _WelcomePageClientState();
}

class _WelcomePageClientState extends State<WelcomePageClient> {
  late final PageController _pageController;
  int _currentPage = 0;

  late final WelcomePageController controller;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller = Get.put(WelcomePageController());
    _pageController = PageController(viewportFraction: 1);
    _autoScroll();
  });
}

  void _autoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (_pageController.hasClients &&
          Get.find<WelcomePageController>().isAutoScrollEnabled.value) {
        _currentPage++;
        final nextPage = _currentPage % restaurants.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  List<dynamic> get restaurants => Get.find<WelcomePageController>().restaurants;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = GetStorage().read('userName') ?? '';
    final welcomeMessage = userName.isNotEmpty ? "Bienvenue, $userName 👋" : "Bienvenue 👋";

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
              Text(
                welcomeMessage,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (userName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "Nom : $userName",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 16),

              // Search Bar
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),

              const SizedBox(height: 16),
ElevatedButton.icon(
  onPressed: controller.filterNearbyRestaurants,
  icon: const Icon(Icons.location_on, color: Colors.white),
  label: const Text("À proximité", style: TextStyle(color: Colors.white)),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
),
              const SizedBox(height: 24),

              const Text(
                "Trouvez votre endroit préféré 🍽️",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Filter Chips
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
        final isSelected = controller.selectedCuisine.value == filter;

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
                color: isSelected ? Colors.black : Colors.grey.shade300,
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
                      final isSelected = controller.selectedCategory.value == cat;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text("${emojis[cat]} $cat"),
                          selected: isSelected,
                          onSelected: (_) {
                            if (cat == "Tous") {
                              controller.selectedCategory.value = ""; // Reset category
                            } else {
                              controller.selectCategory(cat);
                            }
                            controller.applyFilters(); // Toujours appliquer les filtres
                          },
                          selectedColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: isSelected ? Colors.black : Colors.grey.shade300,
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
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
                      final imageUrl = index % 2 == 0
                          ? 'https://restaurant-back-main.onrender.com/uploads/miams.jpg'
                          : 'https://restaurant-back-main.onrender.com/uploads/miams2.jpg';
                      final rating = double.tryParse(restaurant['note']?.toString() ?? '0') ?? 0;

                      return RestaurantCard(
                        restaurant: restaurant,
                        imageUrl: imageUrl,
                        rating: rating,
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              const Text(
                "⭐ Plats les plus populaires",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
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
                "⏰ Notification de réservation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              if (controller.hasUpcomingReservation.value)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.access_time),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Vous avez une réservation dans moins d'une heure !"),
                      ),
                    ],
                  ),
                ),
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
  final String imageUrl;
  final double rating;

  const RestaurantCard({
    required this.restaurant,
    required this.imageUrl,
    required this.rating,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    child: Image.network(
                      imageUrl,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
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
                    color: star < rating ? Colors.amber : Colors.grey.shade300,
                  );
                }),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  final fullImageUrl = restaurant['image'] != null
                      ? 'https://restaurant-back-main.onrender.com/uploads/brunch.jpg}'
                      : imageUrl;
                  Get.to(() => TableReservationPage(
                        restaurant: {
                          ...restaurant,
                          'imageUrl': fullImageUrl,
                        },
                      ));
                },
                icon: const Icon(Icons.event_seat, color: Colors.white),
                label: const Text("Réserver", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size.fromHeight(45),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => RestaurantDetailsPage(restaurant: restaurant));
                },
                icon: const Icon(Icons.info_outline, color: Colors.black),
                label: const Text("Explorer", style: TextStyle(color: Colors.black)),
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
          final imageUrl = 'http://10.0.2.2:3000/uploads/brunch.jpg';

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
                          child: Image.network(
                            imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
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
                                  imageUrl: imageUrl,
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
                        // Action commander
                      },
                      icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 16),
                      label: const Text("Commander", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: Size(screenWidth, 48), // pleine largeur
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
  final String imageUrl;

  const PlatDetailsDialog({required this.plat, required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  Text(plat['name'] ?? 'Plat', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Type : ${plat['type'] ?? '---'}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Prix : ${plat['price'] ?? '--'} DT", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(plat['description'] ?? 'Aucune description disponible.',
                      style: const TextStyle(fontSize: 15, color: Colors.black54)),
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
