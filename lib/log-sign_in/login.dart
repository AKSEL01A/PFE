import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reservini/controllers/login_controller.dart';
import 'package:reservini/log-sign_in/forgotpassword.dart';
import 'package:reservini/log-sign_in/signup.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate the LoginController using GetX
    final loginController = Get.put(LoginController());

    return Scaffold(
backgroundColor: Colors.white,      
body: SafeArea(
        
        child: SingleChildScrollView(
          child: Padding(
          
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50.0),
                const SizedBox(height: 100.0),
                const Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50.0),
                
                // Email TextField
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextField(
                    controller: loginController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: const Color.fromARGB(255, 0, 0, 0),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.grey),
                      floatingLabelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Password TextField
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Obx(() => TextField(
                    controller: loginController.passwordController,
                    obscureText: loginController.obscureText.value,
                    cursorColor: Colors.cyan,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: const TextStyle(color: Colors.grey),
                      floatingLabelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 0, 0, 0)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          loginController.obscureText.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        onPressed: loginController.togglePasswordVisibility,
                      ),
                    ),
                  )),
                ),

                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loginController.isLoading.value ? null : loginController.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Obx(() => loginController.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  SizedBox(width: 14.0),
                                  Icon(Icons.login, color: Colors.white),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>  ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Vous n'avez pas de compte ? ",
                      style: TextStyle(
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>   SignupPage()),
                        );
                      },
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          color: Color.fromARGB(255, 8, 182, 31),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                /*const SizedBox(height: 50.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Divider(color: Colors.black)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Ou connectez-vous avec",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Expanded(
                        child: Divider(color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      //onTap: loginController._loginWithFacebook,
                      child: Image.asset(
                        'lib/assets/images/facebook.png',
                        height: 48.0,
                      ),
                    ),
                    const SizedBox(width: 50.0),

                    GestureDetector(
                      //onTap: loginController._loginWithApple,
                      child: Image.asset(
                        'lib/assets/images/apple.png',
                        height: 48.0,
                      ),
                    ),
                    const SizedBox(width: 50.0),
                    GestureDetector(
                      //onTap: loginController._loginWithGoogle,
                      child: Image.asset(
                        'lib/assets/images/google.png',
                        height: 48.0,
                      ),
                    ),
                  ],
                ),*/

                const SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
