import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alerte_provider.dart';
import '../../models/alerte.dart';
import '../../widgets/alerte_card.dart';

class MedecinHomeScreen extends StatefulWidget {
    const MedecinHomeScreen({Key? key}) : super(key: key);

    @override
    State<MedecinHomeScreen> createState() => _MedecinHomeScreenState();
}

class _MedecinHomeScreenState extends State<MedecinHomeScreen> {
    int _currentIndex = 0;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            backgroundColor: AppColors.secondary,
            elevation: 0,
            title: const Text(
            'BloodLink Médecin',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
            ),
            ),
        ),
        body: _buildBody(),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton.extended(
                onPressed: () {
                    Navigator.pushNamed(context, '/medecin/create-alerte');
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle alerte'),
                )
            : null,
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
            setState(() {
                _currentIndex = index;
            });
            },
            selectedItemColor: AppColors.secondary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_outlined),
                activeIcon: Icon(Icons.list),
                label: 'Mes alertes',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
            ),
            ],
        ),
        );
    }

    Widget _buildBody() {
        switch (_currentIndex) {
        case 0:
            return _buildHomeTab();
        case 1:
            return _buildAlertesTab();
        case 2:
            return _buildProfileTab();
        default:
            return _buildHomeTab();
        }
    }

    Widget _buildHomeTab() {
        return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                ),
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                        return Text(
                        'Bienvenue, ${authProvider.currentUser?.nom ?? "Docteur"}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                        ),
                        );
                    },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                    'Gérez vos demandes de sang',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                    ),
                    ),
                ],
                ),
            ),
            const SizedBox(height: 24),

          // Statistiques rapides
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                children: [
                    Expanded(
                    child: _buildStatCard(
                        icon: Icons.notifications_active,
                        title: 'Alertes actives',
                        value: '0',
                        color: AppColors.primary,
                    ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                    child: _buildStatCard(
                        icon: Icons.check_circle,
                        title: 'Dons reçus',
                        value: '0',
                        color: AppColors.accent,
                    ),
                    ),
                ],
                ),
            ),
            const SizedBox(height: 24),

          // Actions rapides
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                'Actions rapides',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                ),
                ),
            ),
            const SizedBox(height: 16),

            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                children: [
                    _buildActionCard(
                    icon: Icons.add_alert,
                    title: 'Créer une alerte',
                    subtitle: 'Lancer une demande de don de sang',
                    color: AppColors.primary,
                    onTap: () {
                        Navigator.pushNamed(context, '/medecin/create-alerte');
                    },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                    icon: Icons.people,
                    title: 'Trouver des donneurs',
                    subtitle: 'Rechercher des donneurs à proximité',
                    color: AppColors.secondary,
                    onTap: () {
                    // Navigation vers recherche
                    },
                    ),
                ],
                ),
            ),
            ],
        ),
        );
    }

    Widget _buildStatCard({
        required IconData icon,
        required String title,
        required String value,
        required Color color,
    }) {
        return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                ),
                ),
                const SizedBox(height: 4),
                Text(
                title,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                ),
                ),
            ],
            ),
        ),
        );
    }

    Widget _buildActionCard({
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
    }) {
        return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
                children: [
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                        ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                        ),
                        ),
                    ],
                    ),
                ),
                const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 18,
                ),
                ],
            ),
            ),
        ),
        );
    }

    Widget _buildAlertesTab() {
        return const Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(Icons.list_alt, size: 80, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
                'Mes alertes',
                style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                ),
            ),
            SizedBox(height: 8),
            Text(
                'Liste de vos alertes',
                style: TextStyle(color: AppColors.textSecondary),
            ),
            ],
        ),
        );
    }

    Widget _buildProfileTab() {
        final authProvider = Provider.of<AuthProvider>(context);

        return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
            children: [
            // Avatar
            CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.secondary,
                child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
                ),
            ),
            const SizedBox(height: 16),

            // Nom
            Text(
                authProvider.currentUser?.nom ?? 'Médecin',
                style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
                authProvider.currentUser?.email ?? '',
                style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                ),
            ),
            const SizedBox(height: 8),

            // Badge
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                'MÉDECIN',
                style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                ),
                ),
            ),
            const SizedBox(height: 32),

            // Options du profil
            _buildProfileOption(
            icon: Icons.person_outline,
            title: 'Modifier le profil',
            onTap: () {},
            ),
            _buildProfileOption(
            icon: Icons.history,
            title: 'Historique des alertes',
            onTap: () {},
            ),
            _buildProfileOption(
            icon: Icons.settings,
            title: 'Paramètres',
            onTap: () {},
            ),
            _buildProfileOption(
            icon: Icons.help_outline,
            title: 'Aide',
            onTap: () {},
            ),
            const SizedBox(height: 16),// Bouton déconnexion
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                onPressed: () async {
                    await authProvider.logout();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                    );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    ),
                ),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Se déconnecter'),
                    ],
                ),
                ),
            ),
            ],
        ),
        );
    }
    Widget _buildProfileOption({
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        }) {
            return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                    leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.secondary),
                ),
                title: Text(
                    title,
                    style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: onTap,
            ),
        );
    }
}