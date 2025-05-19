import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import QR code package

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  _PurchaseHistoryPageState createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  // Controller for search input
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String selectedFilter = "All"; // Default filter value

  @override
Widget build(BuildContext context) {
  List<Map<String, String>> filteredList = reservationList.where((reservation) {
    bool matchesSearchQuery = reservation["restaurant"]!
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) ||
        reservation["clientId"]!.contains(searchQuery) ||
        reservation["tableNumber"]!.contains(searchQuery);

    bool matchesFilter = selectedFilter == "All" ||
        reservation["status"] == selectedFilter;

    return matchesSearchQuery && matchesFilter;
  }).toList();

  final bool isDarkMode = Get.isDarkMode;

  return Scaffold(
    backgroundColor: isDarkMode ? Colors.black : Colors.white,
    appBar: AppBar(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      title: Text(
        "Historique d'addition",
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Rechercher une réservation...",
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                    prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.filter_list, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: _openFilterDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final reservation = filteredList[index];
                return Card(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.restaurant, color: isDarkMode ? Colors.white : Colors.black),
                    title: Text(
                      "Table: ${reservation["tableNumber"]!}",
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    subtitle: Text(
                      "Client ID: ${reservation["clientId"]} | "
                      "Date: ${reservation["date"]} | "
                      "Prix: ${reservation["price"]}€",
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                    ),
                    trailing: Icon(
                      _getPaymentStatusIcon(reservation["status"]!),
                      color: _getPaymentStatusColor(reservation["status"]!),
                    ),
                    onTap: () {
                      Get.to(() => ReservationDetailsPage(reservation));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}


  // Open filter dialog
  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter by Status"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                RadioListTile<String>(
                  title: const Text("All"),
                  value: "All",
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Valid"),
                  value: "Valid",
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Waiting for Payment"),
                  value: "Waiting for Payment",
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Not Valid"),
                  value: "Not Valid",
                  groupValue: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to get the status icon
  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case "Valid":
        return Icons.check_circle;
      case "Waiting for Payment":
        return Icons.access_time;
      case "Not Valid":
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Helper function to get the status color
  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case "Valid":
        return Colors.green;
      case "Waiting for Payment":
        return Colors.orange;
      case "Not Valid":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Mocked reservation data with the required fields
final List<Map<String, String>> reservationList = [
  {
    "tableNumber": "5",
    "clientId": "12345",
    "restaurant": "Le Gourmet",
    "date": "10 Mars 2025",
    "price": "45",
    "status": "Valid",
  },
  {
    "tableNumber": "3",
    "clientId": "67890",
    "restaurant": "Chez Pierre",
    "date": "15 Février 2025",
    "price": "60",
    "status": "Waiting for Payment",
  },
  {
    "tableNumber": "7",
    "clientId": "11223",
    "restaurant": "Bistro Parisien",
    "date": "5 Janvier 2025",
    "price": "30",
    "status": "Not Valid",
  },
];


class ReservationDetailsPage extends StatelessWidget {
  final Map<String, String> reservation;
  const ReservationDetailsPage(this.reservation, {super.key});

  @override
Widget build(BuildContext context) {
  final bool isDarkMode = Get.isDarkMode;

  String qrData =
      "Reservation for ${reservation["restaurant"]} on ${reservation["date"]}\n"
      "Table: ${reservation["tableNumber"]}\n"
      "Client ID: ${reservation["clientId"]}\n"
      "Price: ${reservation["price"]}€";

  return Scaffold(
    backgroundColor: isDarkMode ? Colors.black : Colors.white,
    appBar: AppBar(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      title: Text(
        "Détails de ${reservation["restaurant"]}",
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Restaurant: ${reservation["restaurant"]}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 10),
          Text("Date: ${reservation["date"]}", style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 10),
          Text("Prix: ${reservation["price"]}€", style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 10),
          Text("Table: ${reservation["tableNumber"]}", style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 10),
          Text("Client ID: ${reservation["clientId"]}", style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 20),
          Center(
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white, // Keep QR code readable
            ),
          ),
        ],
      ),
    ),
  );
}

}
