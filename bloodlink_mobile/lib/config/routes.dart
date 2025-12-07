import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_choice_screen.dart';
import '../screens/auth/register_donneur_screen.dart';
import '../screens/auth/register_medecin_screen.dart';
import '../screens/donneur/donneur_home_screen.dart';
import '../screens/medecin/medecin_home_screen.dart';
import '../screens/medecin/create_alerte_screen.dart';

class AppRoutes {
    static const String splash = '/';
    static const String login = '/login';
    static const String registerChoice = '/register/choice';
    static const String registerDonneur = '/register/donneur';
    static const String registerMedecin = '/register/medecin';
    static const String donneurHome = '/donneur/home';
    static const String medecinHome = '/medecin/home';
    static const String createAlerte = '/medecin/create-alerte';

    static Map<String, WidgetBuilder> getRoutes() {
        return {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        registerChoice: (context) => const RegisterChoiceScreen(),
        registerDonneur: (context) => const RegisterDonneurScreen(),
        registerMedecin: (context) => const RegisterMedecinScreen(),
        donneurHome: (context) => const DonneurHomeScreen(),
        medecinHome: (context) => const MedecinHomeScreen(),
        createAlerte: (context) => const CreateAlerteScreen(),
        };
    }
}