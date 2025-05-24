import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:reservini/controllers/SignupController.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reservini/log-sign_in/login.dart';

class SignupPage extends StatelessWidget {
  final SignupController signupController = Get.put(SignupController());
  final Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } else {
      Get.snackbar("Permission refusée", "Vous devez autoriser l'accès aux photos.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Inscription",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Prénom',
                  icon: Icons.person,
                  onChanged: (value) => signupController.firstname.value = value,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Nom',
                  icon: Icons.person_outline,
                  onChanged: (value) => signupController.lastname.value = value,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => signupController.email.value = value,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Numéro de téléphone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => signupController.phone.value = value,
                ),

                const SizedBox(height: 20),

                Obx(() => _buildTextField(
                      label: 'Mot de passe',
                      icon: Icons.lock,
                      obscureText: signupController.obscureTextPassword.value,
                      onChanged: (value) => signupController.password.value = value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          signupController.obscureTextPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          signupController.obscureTextPassword.value =
                              !signupController.obscureTextPassword.value;
                        },
                      ),
                    )),

                const SizedBox(height: 20),

                Obx(() => _buildTextField(
                      label: 'Confirmer le mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: signupController.obscureTextConfirmPassword.value,
                      onChanged: (value) => signupController.confirmPassword.value = value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          signupController.obscureTextConfirmPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          signupController.obscureTextConfirmPassword.value =
                              !signupController.obscureTextConfirmPassword.value;
                        },
                      ),
                    )),

                const SizedBox(height: 30),

                Obx(() => ElevatedButton.icon(
                      onPressed: signupController.isSigningUp.value
                          ? null
                          : () => signupController.signUp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: signupController.isSigningUp.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'S\'inscrire',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                    )),

                const SizedBox(height: 20),

                _buildLoginRedirect(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required Function(String) onChanged,
  }) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      cursorColor: Colors.black,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
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
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Vous avez déjà un compte ? ",
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
