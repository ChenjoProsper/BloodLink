import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RegisterChoiceScreen extends StatelessWidget {
    const RegisterChoiceScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: SafeArea(
            child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: 20),
                
                const Text(
                    'Créer un compte',
                    style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                const Text(
                    'Choisissez votre profil',
                    style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                
                // Carte Donneur
                _buildProfileCard(
                    context,
                    title: 'Donneur de sang',
                    description: 'Je veux donner mon sang et sauver des vies',
                    icon: Icons.favorite,
                    color: AppColors.primary,
                    onTap: () {
                    Navigator.pushNamed(context, '/register/donneur');
                    },
                ),
                const SizedBox(height: 24),
                
                // Carte Médecin
                _buildProfileCard(
                    context,
                    title: 'Médecin',
                    description: 'Je travaille dans un hôpital et je recherche des donneurs',
                    icon: Icons.local_hospital,
                    color: AppColors.secondary,
                    onTap: () {
                    Navigator.pushNamed(context, '/register/medecin');
                    },
                ),
                ],
            ),
            ),
        ),
        );
    }

    Widget _buildProfileCard(
        BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
    }) {
        return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
                children: [
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    ),
                    child: Icon(
                    icon,
                    size: 40,
                    color: color,
                    ),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                        title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                        ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                        description,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                        ),
                        ),
                    ],
                    ),
                ),
                const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                ),
                ],
            ),
            ),
        ),
        );
    }
}