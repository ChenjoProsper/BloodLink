import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/alerte_service.dart';
import '../../models/alerte.dart';
import '../../models/reponse.dart'; // NÉCESSAIRE
import '../../widgets/alerte_card.dart';
import '../donneur/settings_screen.dart';
import 'create_alerte_screen.dart';
import '../../screens/donneur/alerte_detail_screen.dart'; // Assurez-vous d'avoir cet import

class MedecinHomeScreen extends StatefulWidget {
  const MedecinHomeScreen({Key? key}) : super(key: key);

  @override
  State<MedecinHomeScreen> createState() => _MedecinHomeScreenState();
}

class _MedecinHomeScreenState extends State<MedecinHomeScreen> {
  int _currentIndex = 0;
  List<Alerte> _mesAlertes = [];
  List<Reponse> _reponsesEnAttente = [];
  bool _isLoading = false;

  final _alerteService = AlerteService();
  final _storage = StorageService();
  String? _medecinId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialiser l'ID du médecin et charger les données initiales
  Future<void> _initializeData() async {
    final user = _storage.getUser();
    if (user?.userId != null) {
      _medecinId = user!.userId;
      await _refreshData();
    }
  }

  /// Rafraîchir les alertes créées et les réponses en attente de validation
  Future<void> _refreshData() async {
    if (_medecinId == null) return;
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Chargement parallèle des alertes créées et des réponses à valider
      final results = await Future.wait([
        _alerteService.getAlertesByMedecinId(_medecinId!),
        _alerteService.getReponsesByMedecinId(_medecinId!),
      ]);

      if (!mounted) return;
      setState(() {
        _mesAlertes = results[0] as List<Alerte>;
        // Filtrer les réponses pour n'inclure que celles en attente de validation
        _reponsesEnAttente = (results[1] as List<Reponse>)
            .where((r) => r.alerte.etat == 'REPONDU')
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement des données: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        title: const Text('BloodLink Médecin',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Naviguer et attendre le résultat, puis rafraîchir
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateAlerteScreen()),
                );
                if (result == true) {
                  _refreshData();
                }
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Nouvelle alerte',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: Colors.grey[500],
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Alertes'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.check_circle_outline),
                // Affichage du badge de notification
                if (_reponsesEnAttente.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _reponsesEnAttente.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            label: 'À valider',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Paramètres'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    switch (_currentIndex) {
      case 0:
        return _buildAlertesTab();
      case 1:
        return _buildReponsesTab();
      case 2:
        return const SettingsScreen();
      default:
        return _buildAlertesTab();
    }
  }

  /// Écran pour la liste des alertes créées
  Widget _buildAlertesTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (_mesAlertes.isEmpty) {
            return _buildEmptyState(constraints.maxHeight);
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header Stats
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                        icon: Icons.notifications_active,
                        title: 'Actives',
                        value: _mesAlertes
                            .where((a) =>
                                a.etat == 'EN_COURS' || a.etat == 'REPONDU')
                            .length
                            .toString(),
                        color: AppColors.primary,
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildStatCard(
                        icon: Icons.check_circle,
                        title: 'Terminées',
                        value: _mesAlertes
                            .where((a) => a.etat == 'TERMINER')
                            .length
                            .toString(),
                        color: AppColors.accent,
                      )),
                    ],
                  ),
                ),
                // Liste des alertes
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mesAlertes.length,
                  itemBuilder: (context, index) {
                    final alerte = _mesAlertes[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AlerteDetailsScreen(alerte: alerte),
                          ),
                        );
                        if (result == true) {
                          _refreshData();
                        }
                      },
                      child: AlerteCard(alerte: alerte),
                    );
                  },
                ),
                const SizedBox(height: 80), // Espace pour le FAB
              ],
            ),
          );
        },
      ),
    );
  }

  /// Écran pour la validation des dons
  Widget _buildReponsesTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      child: _reponsesEnAttente.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.thumb_up_off_alt, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Aucun don en attente de validation",
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reponsesEnAttente.length,
              itemBuilder: (context, index) {
                final reponse = _reponsesEnAttente[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(
                        reponse.donneur.nom.isEmpty
                            ? 'Donneur Inconnu'
                            : reponse.donneur.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Alerte: ${reponse.alerte.description}\nGroupe: ${reponse.alerte.gsang.replaceAll('_', ' ')}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () =>
                          _validerAlerte(context, reponse.reponseId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Valider',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Fonction pour valider une alerte (API PATCH /api/v1/reponses/{reponseId}/valider)
  Future<void> _validerAlerte(BuildContext context, String reponseId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(width: 12),
            Text('Validation en cours...'),
          ],
        ),
        duration: Duration(days: 365),
      ),
    );

    final result = await _alerteService.validerAlerte(reponseId);

    scaffoldMessenger.hideCurrentSnackBar();
    if (result['success'] == true) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Don validé avec succès !'),
        backgroundColor: AppColors.accent,
      ));
      await _refreshData(); // Rafraîchir la liste après succès
    } else {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Erreur de validation du don'),
          backgroundColor: AppColors.error));
    }
  }

  /// Widget pour afficher une carte de statistiques
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  /// Widget affiché lorsque la liste des alertes est vide
  Widget _buildEmptyState(double height) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune alerte créée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez votre première alerte pour\ntrouver des donneurs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateAlerteScreen(),
                  ),
                );
                if (result == true) {
                  _refreshData();
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Créer une alerte',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
