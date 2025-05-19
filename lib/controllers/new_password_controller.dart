import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> updatePassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('http://10.0.2.2:3000/auth/reset-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
      throw Exception(error);
    }
  }
}
