import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/alerte_provider.dart';
import '../../widgets/alerte_card.dart';
import '../../models/alerte.dart';

class DonneurHomeScreen extends StatefulWidget {
    const DonneurHomeScreen({Key? key}) : super(key: key);

    @override
    State<DonneurHomeScreen> createState() => _DonneurHomeScreenState();
    }

    class _DonneurHomeScreenState extends State<DonneurHomeScreen> {
    int _currentIndex = 0;
    List<Alerte> _alertes = [];
    bool _isLoading = false;

    @override
    void initState() {
        super.initState();
        _initializeLocation();
    }

    Future<void> _initializeLocation() async {
        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        await locationProvider.getCurrentPosition();
    }

    @override
    Widget build(BuildContext context) {
        final authProvider = Provider.of<AuthProvider>(context);

        return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: const Text(
            'BloodLink',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
            ),
            ),
            actions: [
            IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                // Ouvrir les notifications
                },
            ),
            ],
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
            setState(() {
                _currentIndex = index;
            });
            },
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Historique',
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
            return _buildHistoryTab();
        case 2:
            return _buildProfileTab();
        default:
            return _buildHomeTab();
        }
    }

    Widget _buildHomeTab() {
        return RefreshIndicator(
        onRefresh: _refreshAlertes,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Header avec info utilisateur
                Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                    color: AppColors.primary,
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
                            'Bonjour, ${authProvider.currentUser?.nom ?? "Donneur"}',
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
                        'Prêt à sauver des vies aujourd\'hui ?',
                        style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        ),
                    ),
                    ],
                ),
                ),
                const SizedBox(height: 24),

                // Carte de solde
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accent.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                        children: [
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            ),
                            child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 30,
                            ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                'Mon solde',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                '0 FCFA',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                ),
                                ),
                            ],
                            ),
                        ),
                        const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20,
                        ),
                        ],
                    ),
                    ),
                ),
                ),
                const SizedBox(height: 24),

                // Titre des alertes
                const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                    'Alertes à proximité',
                    style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    ),
                ),
                ),
                const SizedBox(height: 16),

                // Liste des alertes
                _isLoading
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                        ),
                    )
                    : _alertes.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _alertes.length,
                            itemBuilder: (context, index) {
                            return Consumer<LocationProvider>(
                                builder: (context, locationProvider, _) {
                                double? distance;
                                if (_alertes[index].latitude != null &&
                                    _alertes[index].longitude != null) {
                                    distance = locationProvider.calculateDistanceToAlerte(
                                    _alertes[index].latitude!,
                                    _alertes[index].longitude!,
                                    );
                                }

                                return AlerteCard(
                                    alerte: _alertes[index],
                                    distance: distance,
                                    onTap: () {
                                    Navigator.pushNamed(
                                        context,
                                        '/donneur/alerte-details',
                                        arguments: _alertes[index],
                                    );
                                    },
                                    onAccept: () => _accepterAlerte(_alertes[index]),
                                    onRefuse: () => _refuserAlerte(_alertes[index]),
                                );
                                },
                            );
                            },
                        ),
                const SizedBox(height: 24),
            ],
            ),
        ),
        );
    }

    Widget _buildEmptyState() {
        return Center(
        child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
            children: [
                Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                'Aucune alerte pour le moment',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                ),
                ),
                const SizedBox(height: 8),
                Text(
                'Vous serez notifié dès qu\'une alerte\nest lancée près de vous',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                ),
                ),
            ],
            ),
        ),
        );
    }

    Widget _buildHistoryTab() {
        return const Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(Icons.history, size: 80, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
                'Historique des dons',
                style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                ),
            ),
            SizedBox(height: 8),
            Text(
                'Bientôt disponible',
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
                backgroundColor: AppColors.primary,
                child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
                ),
            ),
            const SizedBox(height: 16),

            // Nom
            Text(
                authProvider.currentUser?.nom ?? 'Donneur',
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
            const SizedBox(height: 32),

            // Options du profil
            _buildProfileOption(
                icon: Icons.person_outlined,
                title: 'Modifier le profil',
                onTap: () {
                // Navigation vers édition profil
                },
            ),
            _buildProfileOption(
                icon: Icons.location_on_outlined,
                title: 'Actualiser ma position',
                onTap: () async {
                final locationProvider = Provider.of<LocationProvider>(
                    context,
                    listen: false,
                );
                await locationProvider.getCurrentPosition();
                
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                    content: Text('Position mise à jour'),
                    backgroundColor: AppColors.accent,
                    ),
                );
                },
            ),
            _buildProfileOption(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                // Navigation vers paramètres notifications
                },
            ),
            _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Aide',
                onTap: () {
                // Navigation vers aide
                },
            ),
            const SizedBox(height: 16),
            
            // Bouton déconnexion
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary),
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

    Future<void> _refreshAlertes() async {
        setState(() {
        _isLoading = true;
        });

        // Simuler le chargement des alertes
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
        _isLoading = false;
        });
    }

    void _accepterAlerte(Alerte alerte) {
        showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('Accepter l\'alerte'),
            content: const Text(
            'Êtes-vous sûr de vouloir accepter cette demande de don ?',
            ),
            actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
            ),
            ElevatedButton(
                onPressed: () async {
                Navigator.pop(context);
                
                final alerteProvider = Provider.of<AlerteProvider>(
                    context,
                    listen: false,
                );
                
                // TODO: Récupérer l'ID du donneur depuis le profil
                final success = await alerteProvider.accepterAlerte(
                    alerte.alerteId!,
                    'donneur-id',
                );

                if (!mounted) return;

                if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Alerte acceptée avec succès'),
                        backgroundColor: AppColors.accent,
                    ),
                    );
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Erreur lors de l\'acceptation'),
                        backgroundColor: AppColors.error,
                    ),
                    );
                }
                },
                child: const Text('Accepter'),
            ),
            ],
        ),
        );
    }

    void _refuserAlerte(Alerte alerte) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Alerte refusée'),
            backgroundColor: AppColors.textSecondary,
        ),
        );
    }
}