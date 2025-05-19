import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reservini/controllers/profile_controller.dart';
import 'package:reservini/log-sign_in/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark()),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Obx(() {
  final imagePath = profileController.imagePath.value;
  return GestureDetector(
    onTap: () => profileController.pickImage(),
    child: Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          child: imagePath != null && imagePath.isNotEmpty
              ? null
              : const Icon(Icons.person, size: 50, color: Colors.white),
          backgroundImage: imagePath != null && imagePath.isNotEmpty
              ? FileImage(File(imagePath))
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.edit, size: 16, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}),

                const SizedBox(height: 10),
                Obx(() => Text(
                      profileController.userName.value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                      ),
                    )),
                Obx(() => Text(
                      profileController.userEmail.value,
                      style: TextStyle(color: Get.isDarkMode ? Colors.grey : Colors.grey[700]),
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildProfileOption(Icons.privacy_tip_outlined, "Confidentialité", '/privacy'),
                _buildProfileOption(Icons.history, "Historique d’achats", '/history'),
                _buildProfileOption(Icons.help_outline, "Aide & Support", '/help'),
                _buildProfileOption(Icons.settings_outlined, "Paramètres", '/settings'),
                _buildProfileOption(Icons.person_add_alt_outlined, "Inviter un ami", '/invite'),
                _buildProfileOption(Icons.logout, "Déconnexion", '', isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String route, {bool isLogout = false}) {
    return Card(
      color: Get.isDarkMode ? Colors.grey[900] : const Color.fromARGB(255, 239, 246, 252),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: ListTile(
        leading: Icon(icon, color: Get.isDarkMode ? Colors.white : Colors.black),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Get.isDarkMode ? Colors.white : Colors.black),
        onTap: () async {
  if (isLogout) {
    final box = GetStorage();
    await box.remove('token');
    await box.remove('userName');
    await box.remove('userEmail');

    // ☑️ هنا عرّفت prefs قبل ما نستعملها
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('hasSeenOnboarding', true);

    Get.offAll(() => const LoginScreen());
  } else {
    Get.toNamed(route);
  }
}

      ),
    );
  }
}
