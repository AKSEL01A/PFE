import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:reservini/controllers/history_controller.dart';

class SignupController extends GetxController {
  var firstname = ''.obs;
  var lastname = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  var isSigningUp = false.obs;
  var obscureTextPassword = true.obs;
  var obscureTextConfirmPassword = true.obs;
  final HistoryController historyController = Get.put(HistoryController());

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  Future<void> signUp() async {
    if (firstname.value.isEmpty ||
        lastname.value.isEmpty ||
        email.value.isEmpty ||
        phone.value.isEmpty ||
        password.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar("Erreur", "Veuillez remplir tous les champs",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

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

    isSigningUp.value = true;

    try {
      print('🔁 Tentative d\'inscription...');
      final response = await http.post(
        Uri.parse('https://restaurant-back-main.onrender.com/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': firstname.value.trim(),
          'lastname': lastname.value.trim(),
          'email': email.value.trim(),
          'phone': phone.value.trim(),
          'password': password.value,
          'confirmPassword': confirmPassword.value,
        }),
      );
      print('✅ Requête envoyée, réponse reçue');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final decodedBody = jsonDecode(response.body);
        final token = decodedBody['access_token'];

        if (token != null) {
          final payload = token.split('.')[1];
          final normalized = base64.normalize(payload);
          final payloadMap =
              json.decode(utf8.decode(base64.decode(normalized)));

          final userId = payloadMap['sub'];
          final userEmail = payloadMap['email'];
          final userName = payloadMap['name'];
          final userLastname = payloadMap['lastname'];
          final userPhone = payloadMap['phone'];
          final userRole = payloadMap['role'];

          print('🧠 Utilisateur connecté:');
          print('ID: $userId');
          print('Nom: $userName');
          print('Prénom: $userLastname');
          print('Email: $userEmail');
          print('Téléphone: $userPhone');
          print('Rôle: $userRole');

          // ✅ Stocker localement
          final box = GetStorage();
          box.write('token', token);
          box.write('userId', userId);
          box.write('userName', userName);
          box.write('userLastname', userLastname);
          box.write('userEmail', userEmail);
          box.write('userPhone', userPhone);
          box.write('userRole', userRole);
          historyController.addAction('Inscription', 'Nouveau compte créé pour $userEmail');
        }

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
