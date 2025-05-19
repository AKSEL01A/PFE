import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:reservini/client/home_screen.dart';
import 'package:reservini/common/toast.dart';
import 'package:reservini/client/welcome_page.dart';
import 'package:reservini/server/home_screen.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var obscureText = true.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// 🧠 Decode JWT token to extract userId from `sub` field
  String? extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> json = jsonDecode(decoded);

      return json['sub']?.toString();
    } catch (e) {
      print('❌ Erreur lors du décodage du token: $e');
      return null;
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showToast('Erreur', message: 'Veuillez remplir tous les champs');
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('https://restaurant-back-main.onrender.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login Status: ${response.statusCode}');
      print('Login Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access_token'] as String;
        final role = data['role'] as String? ?? '';
        final userName = data['name'] as String? ?? '';
        final userEmail = data['email'] as String? ?? '';
        final userPhone = data['phone'] as String? ?? '';

        final userId = extractUserIdFromToken(token); // ✅ ID depuis le token

        final box = GetStorage();
        box.write('token', token);
        box.write('userId', userId); // ✅ maintenant userId bien stocké
        box.write('userName', userName);
        box.write('userEmail', userEmail);
        box.write('userPhone', userPhone);

        print('✅ Token enregistré: $token');
        print('✅ ID utilisateur extrait: $userId');

        showToast('Succès', message: 'Connexion réussie');

        if (role == 'serveur') {
          Get.off(() => const ServerHomePage());
        } else {
          Get.off(() => HomePageClient());
        }
      } else {
        final err = jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
        showToast('Erreur', message: err.toString());
      }
    } catch (e) {
      showToast('Erreur', message: 'Problème réseau ou serveur');
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

 Future<void> logout() async {
  final box = GetStorage();

  // ❗ نحتفظو بالـ user_notifications و onboarding
  final notifications = box.read('user_notifications');

  await box.remove('token');
  await box.remove('userId');
  await box.remove('userName');
  await box.remove('userEmail');
  await box.remove('userPhone');

  if (notifications != null) {
    box.write('user_notifications', notifications);
  }

  Get.offAll(() => const WelcomePageClient());
}


  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }
}
