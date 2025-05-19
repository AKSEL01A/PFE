import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          "Confidentialité",
          style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
        ),
        iconTheme: IconThemeData(color: Get.isDarkMode ? Colors.white : Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SectionTitle("Collecte des données"),
            SectionContent("Nous collectons les informations suivantes : nom, e-mail, réservations effectuées, et préférences utilisateur."),
            SectionTitle("Utilisation des données"),
            SectionContent("Vos données sont utilisées pour gérer vos réservations, vous envoyer des notifications et améliorer votre expérience utilisateur."),
            SectionTitle("Partage des données"),
            SectionContent("Nous ne partageons vos données qu'avec les restaurants partenaires pour confirmer vos réservations. Nous ne vendons jamais vos informations personnelles."),
            SectionTitle("Sécurité des données"),
            SectionContent("Vos informations sont stockées de manière sécurisée avec chiffrement et protocoles de protection avancés. Vous pouvez gérer et modifier vos préférences à tout moment."),
            SectionTitle("Vos droits"),
            SectionContent("Vous pouvez demander la suppression de vos données ou leur exportation en nous contactant via l'application."),
          ],
        ),
      ),
    );
  }
}

// Components
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class SectionContent extends StatelessWidget {
  final String text;
  const SectionContent(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Get.isDarkMode ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}
