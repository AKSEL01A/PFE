import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> updatePassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('https://restaurant-back-main.onrender.com/auth/reset-password');

    print('📤 Envoi des données de reset:');
    print('Email: $email');
    print('OTP: $otp');
    print('New Password: $newPassword');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Mot de passe réinitialisé avec succès !');
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
      print('❌ Erreur: $error');
      throw Exception(error);
    }
  }
}
