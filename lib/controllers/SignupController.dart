import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SignupController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  var isSigningUp = false.obs;
  var obscureTextPassword = true.obs;
  var obscureTextConfirmPassword = true.obs;

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }






  Future<void> signUp() async {
    if (name.value.isEmpty ||
        email.value.isEmpty ||
        phone.value.isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar("Erreur", "Veuillez remplir tous les champs",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
  print('🔁 Tentative d\'inscription...');

    if (!isValidEmail(email.value)) {
      Get.snackbar("Erreur", "Adresse email invalide",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar("Erreur", "Les mots de passe ne correspondent pas",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Séparer name en name + lastname
    final parts = name.value.trim().split(" ");
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(" ") : 'vide';

    isSigningUp.value = true;

    try {
      print('🔹 Envoi de la requête vers le backend...');
final response = await http.post(
Uri.parse('https://restaurant-back-main.onrender.com/auth/signup'), 
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'name': firstName,
    'lastname': lastName,
    'email': email.value,
    'phone': phone.value,
    'password': password.value,
    'confirmPassword': confirmPassword.value,
  }),
);
print('✅ Requête envoyée, réponse reçue');


      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        Get.snackbar("Succès", "Compte créé avec succès",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offNamed('/login');
      } else {
        final decoded = jsonDecode(response.body);
        final errorMessage = decoded['message'] is List
            ? (decoded['message'] as List).join("\n")
            : decoded['message'] ?? 'Erreur inconnue';

        Get.snackbar("Erreur", errorMessage,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Erreur", "Une erreur est survenue: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSigningUp.value = false;
    }
  }
}
