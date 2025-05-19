import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  var imagePath = Rxn<String>();       // Pour stocker le chemin de l'image
  var userName = ''.obs;               // Nom utilisateur
  var userEmail = ''.obs;              // Email utilisateur

  @override
  void onInit() {
    super.onInit();
    _loadImage();
    _loadUserInfo();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
      _saveImage(pickedFile.path);
    }
  }

  Future<void> _saveImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', path);
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    imagePath.value = prefs.getString('profile_image');
  }

  void _loadUserInfo() {
    final box = GetStorage();
    userName.value = box.read('userName') ?? 'Utilisateur inconnu';
    userEmail.value = box.read('userEmail') ?? 'Email non disponible';
    print('[✅ ProfileController] Nom récupéré : ${userName.value}');
    print('[✅ ProfileController] Email récupéré : ${userEmail.value}');
  }
}
