// Fichier: screens/donneur_home_screen.dart (VERSION FINALE)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/alerte_card.dart';
import '../../models/alerte.dart';
import '../../models/donneur.dart';
import 'alerte_detail_screen.dart';
import 'settings_screen.dart';

class DonneurHomeScreen extends StatefulWidget {
  const DonneurHomeScreen({Key? key}) : super(key: key);

  @override
  State<DonneurHomeScreen> createState() => _DonneurHomeScreenState();
}

class _DonneurHomeScreenState extends State<DonneurHomeScreen> {
  int _currentIndex = 0;
  List<Alerte> _alertes = [];
  // 💡 Nouveaux états pour l'historique des réponses
  List<dynamic> _responseHistory = [];
  bool _isLoading = false;
  bool _isLoadingHistory =
      false; // 💡 Nouvel état de chargement pour l'historique
  Donneur? _donneurData;
  final _api = ApiService();
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    // Le provider de location est souvent initialisé ici ou dans le main
    // Assurez-vous d'appeler locationProvider.startLocationUpdates(); ailleurs.
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadDonneurData();
    await _loadAlertes();
    // 💡 Charger l'historique au démarrage
    await _loadHistory();
  }

  /// Charger les données du donneur (y compris le solde)
  Future<void> _loadDonneurData() async {
    try {
      final user = _storage.getUser();
      if (user?.userId == null) return;

      // Appel backend pour récupérer les détails du donneur
      final response = await _api.get('/api/v1/donneurs/${user!.userId}');

      if (response.statusCode == 200) {
        setState(() {
          // Assurez-vous que le modèle Donneur.fromJson est mis à jour
          _donneurData = Donneur.fromJson(response.data);
        });
      }
    } catch (e) {
      print('Erreur chargement donneur: $e');
    }
  }

  /// Charger les alertes disponibles depuis le backend
  Future<void> _loadAlertes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_donneurData == null) {
        await _loadDonneurData(); // Assurer que les données sont chargées
        if (_donneurData == null) return;
      }

      // Appel à l'endpoint /api/v1/alertes/actives/{groupeSanguin}
      final response = await _api
          .get('/api/v1/alertes/actives/${_donneurData!.groupeSanguin}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          _alertes = data.map((json) => Alerte.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _alertes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur chargement alertes: $e');
      setState(() {
        _alertes = [];
        _isLoading = false;
      });
    }
  }

  /// 💡 Nouvelle fonction pour charger l'historique des réponses du donneur
  Future<void> _loadHistory() async {
    // S'assurer que les données du donneur sont chargées avant d'appeler l'API
    if (_donneurData == null || _donneurData!.userId == null) {
      await _loadDonneurData();
      if (_donneurData == null || _donneurData!.userId == null) return;
    }

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      // Endpoint basé sur ReponseController.java: GET /api/v1/reponses/donneur/{donneurId}
      final response =
          await _api.get('/api/v1/reponses/donneur/${_donneurData!.userId}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          // data contient List<ReponseResult>
          _responseHistory = data;
        });
      }
    } catch (e) {
      print('Erreur chargement historique: $e');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _refreshData() async {
    // Nous appelons _loadDonneurData ici pour actualiser le solde
    await _loadDonneurData();
    await _loadAlertes();
    // 💡 Actualiser l'historique
    await _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Notifications : Fonctionnalité bientôt disponible'),
                ),
              );
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
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Paramètres',
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
        return const SettingsScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
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
                      colors: [
                        AppColors.accent,
                        AppColors.accent.withOpacity(0.7)
                      ],
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
                            Text(
                              '${_donneurData?.solde.toStringAsFixed(0) ?? "0"} FCFA',
                              style: const TextStyle(
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
                              // 💡 Utilise les nouveaux champs latitude/longitude de l'alerte
                              if (_alertes[index].latitude != null &&
                                  _alertes[index].longitude != null &&
                                  locationProvider.currentPosition != null) {
                                distance =
                                    locationProvider.calculateDistanceToAlerte(
                                  _alertes[index].latitude!,
                                  _alertes[index].longitude!,
                                );
                              }

                              return AlerteCard(
                                alerte: _alertes[index],
                                distance: distance,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AlerteDetailsScreen(
                                        alerte: _alertes[index],
                                      ),
                                    ),
                                  ).then((_) => _refreshData());
                                },
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

  /// 💡 Implémentation du Tab Historique
  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: _loadHistory, // Permet d'actualiser l'historique
      child: _isLoadingHistory
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          : _responseHistory.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune contribution enregistrée',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'L\'historique de vos réponses aux alertes\napparaîtra ici.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _responseHistory.length,
                  itemBuilder: (context, index) {
                    // Le type est dynamic (ReponseResult), accédez aux données via Map
                    final Map<String, dynamic> response =
                        _responseHistory[index];

                    // Assurez-vous que le backend renvoie le champ 'valide'
                    final isValide = response['valide'] == true;
                    // Utiliser l'alerteId complet car il est requis pour les détails si on navigue
                    final alerteIdSnippet = response['alerteId'] != null
                        ? response['alerteId'].toString().substring(0, 8)
                        : 'Inconnue';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isValide
                                ? AppColors.accent.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isValide
                                ? Icons.check_circle_outline
                                : Icons.pending_actions,
                            color:
                                isValide ? AppColors.accent : AppColors.primary,
                          ),
                        ),
                        title: Text(
                          'Réponse à l\'alerte $alerteIdSnippet...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Assurez-vous que 'dateReponse' est renvoyé par le backend
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isValide
                                  ? 'Statut: Don Validé'
                                  : 'Statut: En attente de validation',
                            ),
                            if (response['dateReponse'] != null)
                              Text(
                                // Affichage simplifié de la date (ex: 2023-12-11)
                                'Date: ${response['dateReponse'].toString().split('T')[0]}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                        trailing: Text(
                          'ID Rép.: ${response['reponseId'].toString().substring(0, 4)}...',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        onTap: () {
                          // Optionnel: Naviguer vers les détails de la réponse/alerte
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Détails de la réponse ID: ${response['reponseId']}'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
