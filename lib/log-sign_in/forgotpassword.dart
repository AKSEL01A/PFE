import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reservini/controllers/forgot_password_controller.dart';
import 'package:reservini/log-sign_in/login.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'Mot de passe oublié ?',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 0, 0),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Entrez votre adresse e-mail pour continuer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
            const SizedBox(height: 40.0),
            _buildEmailField(),
            const SizedBox(height: 20.0),
            _buildSendButton(),
            const SizedBox(height: 40.0),
            _buildLoginRedirect(), // ✅ بعد التعديل
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
      child: TextField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: const BorderSide(color: Colors.black),
          ),
          prefixIcon: const Icon(Icons.email, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Obx(() => TextButton(
          onPressed: controller.isButtonDisabled.value ? null : controller.verifyEmail,
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 80),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            elevation: 5,
          ),
          child: controller.isButtonDisabled.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Continuer",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ));
  }

  Widget _buildLoginRedirect() {
    return Wrap( // ✅ استبدلنا Row بـ Wrap لتجنب overflow
      alignment: WrapAlignment.center,
      spacing: 4.0,
      children: [
        const Text(
          "Vous vous souvenez de votre mot de passe ?",
          style: TextStyle(color: Colors.grey, letterSpacing: 0.5),
        ),
        GestureDetector(
          onTap: () => Get.offAll(() => LoginScreen()),
          child: const Text(
            "Se connecter",
            style: TextStyle(
              color: Color.fromARGB(255, 4, 163, 26),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
