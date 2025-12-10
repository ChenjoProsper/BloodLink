// Fichier : lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 CORRECTION APPLIQUÉE :
    // L'appel à _checkAuth (qui modifie l'état via AuthProvider.initialize())
    // est reporté après que le premier frame de la construction est terminé.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // ⚠️ Utiliser listen: false ici est CRUCIAL car nous sommes dans un Future asynchrone
    // et non dans la méthode build.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ceci est la ligne qui appelait notifyListeners() et causait le crash
    // si elle était appelée directement dans initState.
    await authProvider.initialize();

    // Délai pour l'effet visuel du splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      final role = authProvider.currentUser?.role;
      if (role == 'DONNEUR') {
        Navigator.pushReplacementNamed(context, '/donneur/home');
      } else if (role == 'MEDECIN') {
        Navigator.pushReplacementNamed(context, '/medecin/home');
      } else {
        // Si l'utilisateur est authentifié mais n'a pas de rôle reconnu
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bloodtype,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'BloodLink',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Sauver des vies ensemble',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),

            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
