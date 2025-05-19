import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add Get package for dark mode handling
import 'package:reservini/profile/profile.dart'; // Import ProfilePage
import 'package:reservini/server/scan_client_page.dart'; // Scan Reservation Page
import 'package:reservini/server/dashboard_screan.dart'; // Dashboard Page
import 'package:reservini/server/scan_table_page.dart'; // Scan Table Page
import 'package:reservini/server/add_reservation_page.dart'; // Add Reservation Page

class ServerHomePage extends StatefulWidget {
  const ServerHomePage({super.key});

  @override
  _ServerHomePageState createState() => _ServerHomePageState();
}

class HomeController extends GetxController {
  var currentInnerPage = 0.obs;  // Page initiale (0 = AddReservationPage)

  void changeInnerPage(int pageIndex) {
    currentInnerPage.value = pageIndex;
  }
}

class _ServerHomePageState extends State<ServerHomePage> {
  int _selectedIndex = 0; // Default selected index for ServerDashboard
  final HomeController homeController = Get.put(HomeController());

  // List of pages for navigation
  final List<Widget> innerPages = [
    const AddReservationPage(),  // Add Reservation
    const ServerDashboard(),     // Server Dashboard
    const ScanClientPage(),      // Scan Client Page
    const ScanTablePage(),       // Scan Table Page
     ProfilePage(),         // Profile Page
  ];

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => innerPages[homeController.currentInnerPage.value]), // Page content that changes dynamically based on current index
          Positioned(
            bottom: 30, // Position the button 30px from the bottom
            left: 20, // Add left padding
            right: 20, // Add right padding
            child: Container(
              width: MediaQuery.of(context).size.width - 40, // Button width with padding
              height: 70, // Button height
              decoration: BoxDecoration(
                color: Colors.black, // Set background color to black
                borderRadius: BorderRadius.circular(30), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Space icons evenly
                children: [
                  AnimatedScale(
                    duration: Duration(milliseconds: 300), // Animation duration
                    scale: _selectedIndex == 0 ? 1.2 : 1.0, // Scale effect when selected
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                        homeController.changeInnerPage(0); // Navigate to Add Reservation
                      },
                    ),
                  ),
                  AnimatedScale(
                    duration: Duration(milliseconds: 300), // Animation duration
                    scale: _selectedIndex == 2 ? 1.2 : 1.0, // Scale effect when selected
                    child: IconButton(
                      icon: Icon(Icons.qr_code_rounded, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                        homeController.changeInnerPage(2); // Navigate to Scan Client
                      },
                    ),
                  ),
                  AnimatedScale(
                    duration: Duration(milliseconds: 300), // Animation duration
                    scale: _selectedIndex == 1 ? 1.2 : 1.0, // Scale effect when selected
                    child: IconButton(
                      icon: Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                        homeController.changeInnerPage(1); // Navigate to Server Dashboard
                      },
                    ),
                  ),
                  AnimatedScale(
                    duration: Duration(milliseconds: 300), // Animation duration
                    scale: _selectedIndex == 3 ? 1.2 : 1.0, // Scale effect when selected
                    child: IconButton(
                      icon: Icon(Icons.qr_code_rounded, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 3;
                        });
                        homeController.changeInnerPage(3); // Navigate to Scan Table
                      },
                    ),
                  ),
                  AnimatedScale(
                    duration: Duration(milliseconds: 300), // Animation duration
                    scale: _selectedIndex == 4 ? 1.2 : 1.0, // Scale effect when selected
                    child: IconButton(
                      icon: Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 4;
                        });
                        homeController.changeInnerPage(4); // Navigate to Profile Page
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
