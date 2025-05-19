import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class WelcomePageController extends GetxController {
  var restaurants = [].obs;
  var fullList = [].obs;
  var popularPlats = [].obs;
  var isLoading = true.obs;

  var selectedCuisine = "Tous".obs;     // 🍝 origine
  var selectedCategory = "".obs;        // 🍕 type de plat
  var searchText = "".obs;

  var hasUpcomingReservation = false.obs;
  var isAutoScrollEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
    fetchPopularPlats();
    checkUpcomingReservation();
  }

  Future<void> fetchRestaurants() async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      final token = box.read('token');

      final response = await http.get(
        Uri.parse('https://restaurant-back-main.onrender.com/restaurant/restaurant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        fullList.value = data;
        restaurants.value = data;
      } else {
        print('Erreur RESTAURANTS: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception RESTAURANTS: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPopularPlats() async {
    try {
      final box = GetStorage();
      final token = box.read('token');

      final response = await http.get(
        Uri.parse('https://restaurant-back-main.onrender.com/plats/populaires'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        popularPlats.value = jsonDecode(response.body);
      } else {
        print('Erreur PLATS POPULAIRES: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception PLATS POPULAIRES: $e");
    }
  }

  void updateSearch(String value) {
    searchText.value = value;
    isAutoScrollEnabled.value = false;
    applyFilters();
  }

  void selectCuisine(String cuisine) {
    selectedCuisine.value = cuisine;
    applyFilters();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    isAutoScrollEnabled.value = false;
    applyFilters();
  }

  void applyFilters() {
    List<dynamic> filtered = fullList;

    // Filtrage par origine (cuisine)
    if (selectedCuisine.value != "Tous") {
      filtered = filtered.where((r) =>
        r['categorie'] != null &&
        r['categorie'].toString().toLowerCase().contains(selectedCuisine.value.toLowerCase())
      ).toList();
    }

    // Filtrage par type de plat (catégorie)
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((r) =>
        r['specialite'] != null &&
        r['specialite'].toString().toLowerCase().contains(selectedCategory.value.toLowerCase())
      ).toList();
    }

    // Filtrage par texte
    if (searchText.value.isNotEmpty) {
      filtered = filtered.where((r) =>
        r['name'].toString().toLowerCase().contains(searchText.value.toLowerCase())
      ).toList();
    }

    restaurants.value = filtered;
  }

  Future<void> filterNearbyRestaurants() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("GPS désactivé", "Veuillez activer la localisation.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permission refusée", "L'accès à la position est requis.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("Permission refusée", "L'accès est bloqué définitivement.");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final userLat = position.latitude;
      final userLng = position.longitude;

      final nearby = fullList.where((r) {
        final lat = r['latitude'];
        final lng = r['longitude'];
        if (lat == null || lng == null) return false;

        final distance = Geolocator.distanceBetween(
          userLat,
          userLng,
          double.tryParse(lat.toString()) ?? 0.0,
          double.tryParse(lng.toString()) ?? 0.0,
        );

        return distance <= 2000; // 2km
      }).toList();

      restaurants.value = nearby;
      selectedCuisine.value = "À proximité";
    } catch (e) {
      print("Erreur géolocalisation : $e");
      Get.snackbar("Erreur", "Impossible d'obtenir la position.");
    }
  }

  Future<List<dynamic>> fetchUserReservations() async {
    try {
      final box = GetStorage();
      final token = box.read('token');

      final response = await http.get(
        Uri.parse('https://restaurant-back-main.onrender.com/reservations/client'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Erreur réservations : ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur fetchUserReservations: $e");
      return [];
    }
  }

  Future<void> checkUpcomingReservation() async {
    final reservations = await fetchUserReservations();
    final now = DateTime.now();

    hasUpcomingReservation.value = reservations.any((res) {
      final date = DateTime.parse(res['date']);
      final heure = TimeOfDay(
        hour: int.parse(res['heure'].split(":")[0]),
        minute: int.parse(res['heure'].split(":")[1]),
      );

      final reservationTime = DateTime(
        date.year,
        date.month,
        date.day,
        heure.hour,
        heure.minute,
      );

      return reservationTime.difference(now).inMinutes <= 60 && reservationTime.isAfter(now);
    });
  }
}
