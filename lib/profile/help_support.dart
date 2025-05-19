import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reservini/profile/chat_support.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
        title: const Text("Aide & Support"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle("Questions Fréquentes (FAQ)", isDark),
            _buildFAQItem(
              "Comment annuler une réservation ?",
              "Vous pouvez annuler une réservation dans la section 'Mes Réservations'. Cliquez sur la réservation et sélectionnez 'Annuler'.",
              isDark,
            ),
            _buildFAQItem(
              "Puis-je modifier ma réservation ?",
              "Oui, vous pouvez modifier la date ou l'heure en accédant aux détails de votre réservation.",
              isDark,
            ),
            _buildFAQItem(
              "Comment puis-je contacter le restaurant ?",
              "Les coordonnées du restaurant sont disponibles dans les détails de votre réservation.",
              isDark,
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("Contacter le Support", isDark),
            _buildListTile(
              icon: Icons.email,
              color: Colors.blue,
              title: "support@reservini.com",
              subtitle: "Envoyez-nous un e-mail",
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'support@reservini.com',
                  query: 'subject=Aide%20et%20Support',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Impossible d’ouvrir l’e-mail")),
                  );
                }
              },
              isDark: isDark,
            ),
            _buildListTile(
              icon: Icons.phone,
              color: Colors.green,
              title: "+216 97 528 1941",
              subtitle: "Appelez notre assistance",
              onTap: () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: '+21697528941');
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Impossible de passer l’appel")),
                  );
                }
              },
              isDark: isDark,
            ),
            _buildListTile(
              icon: Icons.chat,
              color: Colors.orange,
              title: "Chat en direct",
              subtitle: "Obtenez de l'aide instantanée",
              onTap: () => Get.to(() => const ChatSupportPage()),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("Signaler un Problème", isDark),
            _buildListTile(
              icon: Icons.report_problem,
              color: Colors.red,
              title: "Problème avec une réservation ou un paiement",
              onTap: () => Get.to(() => const ReportIssuePage()),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("Guide d'Utilisation", isDark),
            _buildListTile(
              icon: Icons.help_outline,
              color: Colors.blueGrey,
              title: "Comment utiliser l'application ?",
              onTap: () => Get.to(() => const UserGuidePage()),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isDark) {
    return Card(
      color: isDark ? Colors.grey[850] : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              answer,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            )
          : null,
      onTap: onTap,
    );
  }
}

class ReportIssuePage extends StatelessWidget {
  const ReportIssuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Signaler un Problème"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Décrivez votre problème :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: isDark ? Colors.grey[850] : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                maxLines: 5,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: "Expliquez votre problème ici...",
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action d’envoi
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.teal : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Envoyer",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Guide d'Utilisation"),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Comment utiliser l'application ?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("1. Connectez-vous ou créez un compte."),
            Text("2. Recherchez un restaurant et choisissez une date."),
            Text("3. Confirmez votre réservation."),
            Text("4. Consultez votre historique et gérez vos réservations."),
            Text("5. Contactez l'assistance si nécessaire."),
          ],
        ),
      ),
    );
  }
}
