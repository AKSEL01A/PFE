import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InviteFriendPage extends StatefulWidget {
  const InviteFriendPage({super.key});

  @override
  _InviteFriendPageState createState() => _InviteFriendPageState();
}

class _InviteFriendPageState extends State<InviteFriendPage> {
  String referralCode = "RESERVINI123"; // Example code, could be generated dynamically

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is enabled
    bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
       
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("🌟 Programme de Parrainage", isDark),
            Text(
              "Invitez vos amis à rejoindre Reservini et recevez une réduction sur votre prochaine réservation !",
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 20),

            // Referral Code Section
            
            // Sharing Options
            _buildSectionTitle("📤 Partager avec vos amis", isDark),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareButton(Icons.phone, "WhatsApp", "https://reservini.com/invite/$referralCode", isDark),
                _buildShareButton(Icons.email, "E-mail", "https://reservini.com/invite/$referralCode", isDark),
                _buildShareButton(Icons.share, "Autres", "https://reservini.com/invite/$referralCode", isDark),
              ],
            ),
            const SizedBox(height: 20),

            // Track Invitations
          
          ],
        ),
      ),
    );
  }

  // Title Widget
  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  // Share Button Widget
  Widget _buildShareButton(IconData icon, String label, String link, bool isDark) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: isDark ? Colors.white : Colors.blue),
          onPressed: () {
            Share.share("Rejoignez Reservini avec mon code $referralCode : $link");
          },
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
        ),
      ],
    );
  }

  // Mock list of invited friends
 
} 