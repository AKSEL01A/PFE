import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reservini/client/MyReservations_page.dart';
import 'package:reservini/client/notifications_page.dart';
import 'package:reservini/client/reservation_page.dart';
import 'package:reservini/client/welcome_page.dart';
import 'package:reservini/profile/profile.dart';
import 'package:reservini/client/all_dishes_page.dart'; // assure-toi que ce fichier existe

class HomePageClient extends StatefulWidget {
  const HomePageClient({super.key});

  @override
  _ClientHomePageState createState() => _ClientHomePageState();
}

class HomeController extends GetxController {
  var currentInnerPage = 2.obs; // par défaut: accueil

  void changeInnerPage(int pageIndex) {
    currentInnerPage.value = pageIndex;
  }
}

class _ClientHomePageState extends State<HomePageClient> {
  int _selectedIndex = 2;
  final HomeController homeController = Get.put(HomeController());

  final List<Widget> innerPages = [
    MyReservationsPage(),    // 0
    AllDishesPage(),         // 1
    WelcomePageClient(),     // 2
    NotificationsPage(),     // 3
    ProfilePage(),           // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Obx(() => innerPages[homeController.currentInnerPage.value]),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.book_online),     // Mes Réservations
                  _buildNavItem(1, Icons.fastfood),        // Tous les plats
                  _buildNavItem(2, Icons.home),            // Accueil
                  _buildNavItem(3, Icons.notifications),   // Notifications
                  _buildNavItem(4, Icons.person),          // Profil
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    return AnimatedScale(
      scale: _selectedIndex == index ? 1.2 : 1.0,
      duration: Duration(milliseconds: 300),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {
          setState(() => _selectedIndex = index);
          homeController.changeInnerPage(index);
        },
      ),
    );
  }
}
