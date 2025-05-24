import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reservini/controllers/history_controller.dart';

class ActivityHistoryPage extends StatelessWidget {
  final HistoryController controller = Get.put(HistoryController());

  ActivityHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Mon activité"),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: controller.clearHistory,
          )
        ],
      ),
      body: Obx(() {
        if (controller.history.isEmpty) {
          return const Center(child: Text("Aucune activité enregistrée."));
        }

        return ListView.builder(
          itemCount: controller.history.length,
          itemBuilder: (context, index) {
            final item = controller.history[index];
            return ListTile(
              leading: Icon(Icons.history, color: isDarkMode ? Colors.white : Colors.black),
              title: Text(item['type'] ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
              subtitle: Text(item['description'] ?? '', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
              trailing: Text(item['date'] ?? '', style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black45)),
            );
          },
        );
      }),
    );
  }
}
