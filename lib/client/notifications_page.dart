import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reservini/controllers/notifications_controller.dart';

class NotificationsPage extends StatelessWidget {
  final NotificationsController controller = Get.find<NotificationsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications 🔔', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  tooltip: "Vider les notifications",
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Confirmation",
                      content: const Text("Supprimer toutes les notifications ?"),
                      confirm: ElevatedButton(
                        onPressed: () {
                          controller.notifications.clear();
                          Get.back();
                        },
                        child: const Text("Oui"),
                      ),
                      cancel: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Non"),
                      ),
                    );
                  },
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "Aucune notification pour le moment.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return Card(
              color: Colors.grey[100],
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification['color'],
                  child: Icon(notification['icon'], color: Colors.white),
                ),
                title: Text(notification['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notification['description']),
                    const SizedBox(height: 4),
                    Text(notification['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
