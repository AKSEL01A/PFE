import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reservini/client/MyReservations_page.dart';
import 'package:reservini/client/notifications_page.dart';
import 'package:reservini/client/reservation_page.dart';
import 'package:reservini/client/welcome_page.dart';
import 'package:reservini/profile/profile.dart';

class HomePageClient extends StatelessWidget {
  HomePageClient({Key? key}) : super(key: key);

  final HomeController homeController = Get.put(HomeController());

  final List<Widget> innerPages = [
    WelcomePageClient(),                 // 0: Accueil
    TableReservationPage(restaurant: {}), // 1: Réserver une Table
    MyReservationsPage(),               // 2: Mes Réservations
    NotificationsPage(),                // 3: Notifications
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => innerPages[homeController.currentInnerPage.value]),
      bottomNavigationBar: BottomNavBar(homeController: homeController),
      backgroundColor: Colors.white,
    );
  }
}

class HomeController extends GetxController {
  var currentInnerPage = 0.obs;

  void changeInnerPage(int pageIndex) {
    currentInnerPage.value = pageIndex;
  }
}

class BottomNavBar extends StatefulWidget {
  final HomeController homeController;

  const BottomNavBar({Key? key, required this.homeController}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 4) {
      Get.to(() => ProfilePage());
    } else {
      widget.homeController.changeInnerPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //_buildIcon(Icons.calendar_today, 1),
            _buildIcon(Icons.bookmark_added, 2),
                        _buildIcon(Icons.home, 0),

            _buildIcon(Icons.notifications, 3),
            _buildIcon(Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return AnimatedScale(
      duration: Duration(milliseconds: 300),
      scale: _selectedIndex == index ? 1.2 : 1.0,
      curve: Curves.easeInOut,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () => _onItemTapped(index),
      ),
    );
  }
}
