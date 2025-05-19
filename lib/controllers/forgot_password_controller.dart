import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:reservini/common/toast.dart';

class ForgotPasswordController extends GetxController {
  var emailController = TextEditingController();
  var isButtonDisabled = false.obs;

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> verifyEmail() async {
  String email = emailController.text.trim();
  print("📩 verifyEmail called"); // debug
  print("📧 Email saisi: $email");

  if (!_validateEmail(email)) {
    showToast('Erreur', message: 'Veuillez entrer une adresse e-mail valide.');
    return;
  }

  isButtonDisabled.value = true;

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    print("📨 HTTP status code: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      showToast('Succès', message: 'Email envoyé.');
      print("✅ Navigating to reset page with email: $email");

      Get.toNamed('/reset-password', arguments: {'email': email});
      print("✅ Get.toNamed executed");
    } else {
      var errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
      showToast('Erreur', message: errorMessage.toString());
      print("❌ Error response: $errorMessage");
    }
  } catch (e) {
    showToast('Erreur', message: 'Problème de connexion au serveur.');
    print("❌ Exception: $e");
  }

  isButtonDisabled.value = false;
}

}
