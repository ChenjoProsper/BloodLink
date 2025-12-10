import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/alerte_service.dart';
import '../../models/alerte.dart';
import '../../models/reponse.dart';
import '../../widgets/alerte_card.dart'; // Assurez-vous d'avoir ce widget
import '../donneur/settings_screen.dart';
import 'create_alerte_screen.dart';

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

  Future<void> _initializeData() async {
    final user = _storage.getUser();
    if (user?.userId != null) {
      _medecinId = user!.userId;
      await _refreshData();
    }
  }

  Future<void> _refreshData() async {
    if (_medecinId == null) return;
    setState(() => _isLoading = true);

    // Chargement parallèle des alertes créées et des réponses à valider
    final results = await Future.wait([
      _alerteService.getAlertesByMedecinId(_medecinId!),
      _alerteService.getReponsesByMedecinId(_medecinId!),
    ]);

    setState(() {
      _mesAlertes = results[0] as List<Alerte>;
      _reponsesEnAttente = results[1] as List<Reponse>;
      _isLoading = false;
    });
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
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateAlerteScreen()));
                _refreshData();
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle alerte'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.secondary,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Alertes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline), label: 'À valider'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'Paramètres'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
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

  Widget _buildAlertesTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header Stats (simplifié)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                    icon: Icons.notifications_active,
                    title: 'Actives',
                    value: _mesAlertes
                        .where(
                            (a) => a.etat == 'EN_COURS' || a.etat == 'REPONDU')
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
            if (_mesAlertes.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text("Aucune alerte créée"))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mesAlertes.length,
                // Utilisez votre widget AlerteCard si disponible, sinon utilisez ListTile
                itemBuilder: (context, index) =>
                    AlerteCard(alerte: _mesAlertes[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReponsesTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _reponsesEnAttente.isEmpty
          ? const Center(child: Text("Aucun don en attente de validation"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reponsesEnAttente.length,
              itemBuilder: (context, index) {
                final reponse = _reponsesEnAttente[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    // Utilise les données du donneur bricolé (qui ne feront plus crasher l'app)
                    title: Text(reponse.donneur.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Alerte: ${reponse.alerte.description}\nEmail: ${reponse.donneur.email}'),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () =>
                          _validerAlerte(context, reponse.reponseId),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent),
                      child: const Text('Valider',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _validerAlerte(BuildContext context, String reponseId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger
        .showSnackBar(const SnackBar(content: Text('Validation en cours...')));

    final result = await _alerteService.validerAlerte(reponseId);

    scaffoldMessenger.hideCurrentSnackBar();
    if (result['success'] == true) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Validé !')));
      await _refreshData();
    } else {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Erreur de validation'),
          backgroundColor: AppColors.error));
    }
  }

  Widget _buildStatCard(
      {required IconData icon,
      required String title,
      required String value,
      required Color color}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
