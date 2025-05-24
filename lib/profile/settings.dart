import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:reservini/controllers/notifications_controller.dart';
import 'package:reservini/controllers/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reservini/log-sign_in/login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ProfileController profileController = Get.put(ProfileController());
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

Future<void> _toggleNotifications(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('notifications', value);

  setState(() {
    notificationsEnabled = value;
  });

  final notifCtrl = Get.find<NotificationsController>();
  notifCtrl.notificationsEnabled.value = value;

  if (!value) {
    notifCtrl.notifications.clear();
    await notifCtrl.saveNotificationsToStorage();
  }
}


  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text("Paramètres", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Notifications"),
          SwitchListTile(
            title: Text("Recevoir des notifications",
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            subtitle: Text("Activer/Désactiver les rappels et promotions",
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            value: notificationsEnabled,
            onChanged: _toggleNotifications,
            activeColor: Colors.green,
            inactiveTrackColor: Colors.grey,
          ),
          const Divider(height: 32),
          _buildSectionTitle("Mon Profil"),
          ListTile(
            leading: Obx(() {
  final imagePath = profileController.imagePath.value;
  return CircleAvatar(
    radius: 30,
    backgroundColor: Colors.grey[300],
    backgroundImage: imagePath != null && imagePath.isNotEmpty
        ? FileImage(File(imagePath))
        : const AssetImage('lib/assets/images/profile_picture.png') as ImageProvider,
  );
}),

            title: Obx(() => Text(
              profileController.userName.value,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            )),
            subtitle: Obx(() => Text(
              profileController.userEmail.value,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            )),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: isDark ? Colors.white70 : Colors.grey),
              onPressed: () {
                Get.to(() => const EditProfilePage());
              },
            ),
          ),
          const Divider(height: 32),
          _buildSectionTitle("Langue"),
          ListTile(
            leading: Icon(Icons.language, color: isDark ? Colors.tealAccent : Colors.green),
            title: Text("Sélectionner une langue",
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            subtitle: Text("Français, Anglais, etc.",
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            onTap: () => Get.to(() => const LanguageSelectionPage()),
          ),
          const Divider(height: 32),
          _buildSectionTitle("Sécurité"),
          ListTile(
            leading: Icon(Icons.lock, color: isDark ? Colors.orangeAccent : Colors.orange),
            title: Text("Changer le mot de passe",
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            onTap: () => Get.to(() => const ChangePasswordPage()),
          ),
          ListTile(
            leading:
                Icon(Icons.phone_android, color: isDark ? Colors.tealAccent : Colors.teal),
            title: Text("Changer le numéro de téléphone",
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            onTap: () => Get.to(() => const ChangePhoneNumberPage()),
          ),
          const Divider(height: 32),
          
          _buildSectionTitle("Compte"),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text("Supprimer le compte",
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            subtitle: Text("Cette action est irréversible",
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? Colors.white : Colors.black)),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Get.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          "Supprimer le compte",
          style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.",
          style: TextStyle(color: Get.isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Annuler",
              style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              final box = GetStorage();
              final token = box.read("token");
              final userId = box.read("userId");

              print("🧾 ID: $userId");
              print("🔐 TOKEN: $token");

              if (token == null || userId == null) {
                Get.snackbar("Erreur", "Utilisateur non authentifié");
                return;
              }

              // 1. Annuler toutes les réservations
await http.patch(
  Uri.parse("https://restaurant-back-main.onrender.com/reservations/cancel-all/$userId"),
  headers: {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  },
);

// 2. Supprimer le compte
final response = await http.delete(
  Uri.parse("https://restaurant-back-main.onrender.com/user/$userId/force-delete"),
  headers: {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  },
);

print("🗑️ STATUS: ${response.statusCode}");
print("🗑️ BODY: ${response.body}");



              try {
                final response = await http.delete(
                  Uri.parse("https://restaurant-back-main.onrender.com/user/$userId"),
                  headers: {
                    "Authorization": "Bearer $token",
                    "Content-Type": "application/json",
                  },
                );

                print("🗑️ STATUS: ${response.statusCode}");
                print("🗑️ BODY: ${response.body}");

                if (response.statusCode == 200) {
                  await box.erase();
                  Get.offAll(() => const LoginScreen());
                  Get.snackbar("Succès", "Compte supprimé avec succès");
                } else {
                  Get.snackbar("Erreur", "Échec de la suppression du compte");
                }
              } catch (e) {
                Get.snackbar("Erreur", "Erreur inattendue: $e");
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

}





class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final profileController = Get.find<ProfileController>();
    final nameController = TextEditingController(text: profileController.userName.value);
    final emailController = TextEditingController(text: profileController.userEmail.value);
    final box = GetStorage();

    Future<void> updateProfile() async {
      final updatedUser = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
      };

      final userId = box.read("userId");
      final token = box.read("token");

      // DEBUG
      print("🆔 ID: $userId");
      print("📧 Email: ${updatedUser['email']}");
      print("👤 Name: ${updatedUser['name']}");
      print("🔐 Token: $token");

      if (userId == null || token == null) {
        Get.snackbar("Erreur", "Utilisateur non authentifié. Reconnectez-vous.");
        return;
      }

      try {
        final response = await http.patch(
          Uri.parse("https://restaurant-back-main.onrender.com/user/$userId"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(updatedUser),
        );

        print("📥 Status: ${response.statusCode}");
        print("📥 Body: ${response.body}");

        if (response.statusCode == 200) {
          profileController.userName.value = updatedUser['name']!;
          profileController.userEmail.value = updatedUser['email']!;
          Get.back();
          Get.snackbar("Succès", "Profil mis à jour ✅");
        } else {
          Get.snackbar("Erreur", "Échec de la mise à jour ❌");
        }
      } catch (e) {
        print("❌ Exception: $e");
        Get.snackbar("Erreur", "Erreur inattendue : $e");
      }
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Modifier le Profil"),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20),
      ),
      body: Padding(
  padding: const EdgeInsets.all(20.0),
  child: ListView(
    children: [
      Center(
        child: Obx(() {
          final imagePath = profileController.imagePath.value;
          return CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage: imagePath != null && imagePath.isNotEmpty
                ? FileImage(File(imagePath))
                : const AssetImage('lib/assets/images/profile_picture.png') as ImageProvider,
          );
        }),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: nameController,
        decoration: InputDecoration(labelText: "Nom"),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(labelText: "E-mail"),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          "Enregistrer",
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    ],
  ),
),

    );
  }
} 



class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final box = GetStorage();

    final activeLanguages = {
      'Français': const Locale('fr', 'FR'),
    };

    final comingSoonLanguages = {
      'English': 'lib/assets/images/uk.png',
      'العربية': 'lib/assets/images/pa.png',
      'Español': 'lib/assets/images/sp.png',
    };

    final languageFlags = {
      'Français': 'lib/assets/images/fr.png',
    };

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Langue"),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Langue disponible :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...activeLanguages.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListTile(
                onTap: () {
                  final selectedLocale = entry.value;
                  box.write("language", selectedLocale.languageCode);
                  Get.updateLocale(selectedLocale);
                  Navigator.pop(context);
                },
                leading: Image.asset(languageFlags[entry.key]!, width: 30, height: 20),
                title: Text(entry.key, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                tileColor: isDark ? Colors.grey[800] : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Bientôt disponibles :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...comingSoonLanguages.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: ListTile(
                leading: Image.asset(entry.value, width: 30, height: 20, color: Colors.grey),
                title: Text(
                  entry.key,
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                trailing: Text("Bientôt", style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                tileColor: isDark ? Colors.grey[900] : Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                enabled: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}





class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isDark = Get.isDarkMode;
    final box = GetStorage();

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black, width: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Changer le mot de passe"),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.lock, size: 80, color: isDark ? Colors.white : Colors.black),
            const SizedBox(height: 20),
            TextField(
              controller: currentPasswordController,
              decoration: inputDecoration("Mot de passe actuel"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: inputDecoration("Nouveau mot de passe"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: inputDecoration("Confirmer le mot de passe"),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 300,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
  final current = currentPasswordController.text.trim();
  final newPass = newPasswordController.text.trim();
  final confirm = confirmPasswordController.text.trim();

  print("🟡 Mot de passe actuel: $current");
  print("🟡 Nouveau mot de passe: $newPass");
  print("🟡 Confirmation: $confirm");

  if (newPass != confirm) {
    print("❌ Les mots de passe ne correspondent pas");
    Get.snackbar("Erreur", "Les mots de passe ne correspondent pas");
    return;
  }

  final token = box.read("token");

  if (token == null) {
    print("❌ Token introuvable: l'utilisateur n'est pas connecté.");
    Get.snackbar("Erreur", "Utilisateur non authentifié. Veuillez vous reconnecter.");
    return;
  }

  print("🔐 TOKEN récupéré: $token");

  try {
    final response = await http.post(
  Uri.parse("https://restaurant-back-main.onrender.com/auth/change-password"),
  headers: {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  },
  body: jsonEncode({
    "oldPassword": current,
    "newPassword": newPass,
    "confirmPassword": confirm,
  }),
);

    print("📥 Status Code: ${response.statusCode}");
    print("📥 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      print("✅ Mot de passe changé avec succès !");
      Get.back();
      Get.snackbar("Succès", "Mot de passe modifié avec succès");
    } else {
      final msg = jsonDecode(response.body)['message'] ?? "Erreur inconnue";
      print("❌ Erreur côté serveur: $msg");
      Get.snackbar("Erreur", msg.toString());
    }
  } catch (e) {
    print("❌ Exception attrapée: $e");
    Get.snackbar("Erreur", "Erreur inattendue : $e");
  }
},
                icon: const Icon(Icons.save),
                label: Text("Enregistrer", style: TextStyle(color: isDark ? Colors.black : Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class ChangePhoneNumberPage extends StatelessWidget {
  const ChangePhoneNumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();
    final isDark = Get.isDarkMode;
    final box = GetStorage();

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black, width: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Changer le numéro"),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.phone_android, size: 80, color: isDark ? Colors.white : Colors.black),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: inputDecoration("Nouveau numéro de téléphone"),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 300,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final phone = phoneController.text.trim();
                  final token = box.read("token");
                  final userId = box.read("userId");

                  // DEBUG: Vérification token et ID
                  print("📦 TOKEN: $token");
                  print("👤 USER ID: $userId");
                  print("📱 NEW PHONE: $phone");

                  if (token == null || userId == null) {
                    Get.snackbar("Erreur", "Utilisateur non authentifié. Reconnectez-vous.");
                    return;
                  }

                  try {
                    final response = await http.patch(
                      Uri.parse("https://restaurant-back-main.onrender.com/user/$userId"),
                      headers: {
                        "Content-Type": "application/json",
                        "Authorization": "Bearer $token",
                      },
                      body: jsonEncode({"phone": phone}),
                    );

                    // DEBUG: Affichage de la réponse
                    print('🔁 STATUS: ${response.statusCode}');
                    print('📦 BODY: ${response.body}');

                    if (response.statusCode == 200) {
                      Get.back();
                      Get.snackbar("Succès", "Numéro mis à jour ✅");
                    } else {
                      Get.snackbar("Erreur", "Échec de la mise à jour ❌");
                    }
                  } catch (e) {
                    print("❌ Exception: $e");
                    Get.snackbar("Erreur", "Erreur inattendue : $e");
                  }
                },
                icon: const Icon(Icons.save),
                label: Text("Enregistrer", style: TextStyle(color: isDark ? Colors.black : Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
