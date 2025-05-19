import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add Get package for dark mode handling

// Widget pour afficher le tableau de bord du serveur
class ServerDashboard extends StatelessWidget {
  const ServerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.isDarkMode to check if dark mode is enabled
    final bool isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color.fromARGB(255, 25, 25, 25) : Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          Text(
            "DASHBOARD",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildServerInfoCard(isDarkMode),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, // Affichage en grille 2x2
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildStatCard("Tables Disponibles", "12", Colors.green, Icons.event_seat),
                      _buildStatCard("Tables Occupées", "8", Colors.red, Icons.block),
                      _buildStatCard("Chiffre d'affaires", "2500 TND", Colors.blue, Icons.attach_money),
                      _buildStatCard("Commandes en attente", "5", Colors.orange, Icons.pending_actions),
                      _buildStatCard("Clients servis", "34", Colors.purple, Icons.people),
                      _buildStatCard("Temps moyen de service", "15 min", Colors.teal, Icons.timer),
                      _buildStatCard("Pourboires reçus", "150 TND", Colors.indigo, Icons.wallet_giftcard),
                      _buildStatCard("Réservations aujourd'hui", "7", Colors.pink, Icons.book_online),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerInfoCard(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("lib/assets/images/server.jpg"),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nom: Mohamed Salah",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    "ID: 12345",
                    style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: color.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
