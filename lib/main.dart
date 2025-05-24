import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reservini/client/MyReservations_page.dart';
import 'package:reservini/client/home_screen.dart';
import 'package:reservini/controllers/confirmation_reservation_controller.dart';
import 'package:reservini/controllers/login_controller.dart';
import 'package:reservini/controllers/notifications_controller.dart';
import 'package:reservini/controllers/welcom_page_controller.dart';
import 'package:reservini/log-sign_in/newpassword.dart';
import 'package:reservini/profile/activity_history_page.dart';
import 'package:reservini/profile/help_support.dart';
import 'package:reservini/profile/invite_a_friend.dart';
import 'package:reservini/profile/privacy_page.dart';
import 'package:reservini/profile/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'onboarding_page.dart';
import 'package:google_fonts/google_fonts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Injecter les contrôleurs
  Get.put(NotificationsController()); // ✅ obligatoire pour éviter l'erreur
  Get.put(LoginController()); // 💥 ضروري باش تبقى الأمور مربوطة*
  Get.put(ConfirmationReservationController()); // ← instancier UNE SEULE FOIS ici

Get.put(WelcomePageController()); // 💡 لازم لتفادي الخطأ

  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
theme: ThemeData(
  fontFamily: GoogleFonts.poppins().fontFamily,
),      home: const LandingPage(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const LandingPage()),
        GetPage(name: '/privacy', page: () => PrivacyPage()),
        GetPage(name: '/history', page: () => ActivityHistoryPage()),

        GetPage(name: '/help', page: () => const HelpSupportPage()),
        GetPage(name: '/settings', page: () => const SettingsPage()),
        GetPage(name: '/invite', page: () => const InviteFriendPage()),
        GetPage(name: '/reset-password', page: () => const ResetPasswordScreen()),
        GetPage(name: '/My-Res', page: () =>  MyReservationsPage()),


      ],
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      setState(() {
        _showOnboarding = true;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => HomePageClient());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: _showOnboarding! ? OnboardingPage() : const SizedBox(),
    );
  }
}
