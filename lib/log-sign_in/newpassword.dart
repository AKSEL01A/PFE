import 'package:flutter/material.dart';
import 'package:reservini/common/toast.dart';
import 'package:reservini/log-sign_in/login.dart';
import 'package:get/get.dart';
import 'package:reservini/controllers/new_password_controller.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final tokenController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late String email;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    email = Get.arguments['email'] ?? '';
  }

  Future<void> _submitReset() async {
    final token = tokenController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      showToast('Erreur', message: 'Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await ApiService.updatePassword(
        email: email,
        otp: token,
        newPassword: password,
      );

      showToast('Succès', message: 'Mot de passe réinitialisé.');
      Get.offAll(() => LoginScreen());
    } catch (e) {
      showToast('Erreur', message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Widget _buildInputField(
      TextEditingController controller, String labelText, String title,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            cursorColor: Colors.black,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: labelText,
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Réinitialiser le mot de passe",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Réinitialisez votre mot de passe 🔐 en saisissant le code reçu par email et en choisissant un nouveau mot de passe.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 30),
              _buildInputField(tokenController, "Code reçu", "Code de réinitialisation"),
              _buildInputField(passwordController, "Nouveau mot de passe", "Nouveau mot de passe", obscure: true),
              _buildInputField(confirmPasswordController, "Confirmer mot de passe", "Confirmer le mot de passe", obscure: true),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _submitReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Réinitialiser",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
