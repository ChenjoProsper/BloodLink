// Fichier: screens/medecin/create_alerte_screen.dart (VERSION FINALE)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/alerte_provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/location_provider.dart';
import '../../core/services/medecin_service.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/alerte.dart';

class CreateAlerteScreen extends StatefulWidget {
  const CreateAlerteScreen({Key? key}) : super(key: key);

  @override
  State<CreateAlerteScreen> createState() => _CreateAlerteScreenState();
}

class _CreateAlerteScreenState extends State<CreateAlerteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _remunerationController = TextEditingController();
  final _medecinService = MedecinService();
  final _storage = StorageService();

  String? _selectedgsang;
  Map<String, double>? _medecinCoords;
  // Stocke les résultats de la recommandation (List<UserResult> en réalité)
  List<dynamic> _donneurRecommandes = [];
  bool _isLoadingCoords = false;
  bool _showRecommandations = false;

  final List<String> _groupesSanguins = [
    'A_POSITIF',
    'A_NEGATIF',
    'B_POSITIF',
    'B_NEGATIF',
    'AB_POSITIF',
    'AB_NEGATIF',
    'O_POSITIF',
    'O_NEGATIF',
  ];

  @override
  void initState() {
    super.initState();
    _loadMedecinCoordinates();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _remunerationController.dispose();
    super.dispose();
  }

  /// Charger les coordonnées du médecin connecté
  Future<void> _loadMedecinCoordinates() async {
    setState(() {
      _isLoadingCoords = true;
    });

    final user = _storage.getUser();
    if (user?.userId != null) {
      // Appel au MedecinService pour récupérer les coordonnées GPS
      final coords =
          await _medecinService.getCoordonnesByMedecinId(user!.userId);

      if (coords != null) {
        setState(() {
          _medecinCoords = coords;
        });
      } else {
        // Coordonnées non disponibles (le médecin doit avoir une adresse GPS associée)
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Coordonnées GPS non disponibles pour votre hôpital. Veuillez contacter l\'administrateur.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() {
      _isLoadingCoords = false;
    });
  }

  /// Afficher les donneurs recommandés (dans un rayon de 5km)
  Future<void> _showDonneurRecommandes() async {
    if (_medecinCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordonnées GPS non disponibles'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Si on change de groupe sanguin après avoir cliqué, on rafraîchit l'affichage
    if (_selectedgsang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un groupe sanguin d\'abord.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _showRecommandations = true;
      _donneurRecommandes = []; // Clear la liste avant de charger
    });

    final alerteProvider = Provider.of<AlerteProvider>(context, listen: false);

    // L'API de recommandation ne prend que lat/long, le filtre GS est côté client (ici on ne filtre pas)
    // Côté backend (AlerteServiceImpl.java), la recommandation ne filtre que par distance (<= 5km)
    final donneurs = await alerteProvider.getRecommendations(
      _medecinCoords!['latitude']!,
      _medecinCoords!['longitude']!,
      // Note: Le groupe sanguin est ignoré par l'API de recommandation actuelle
    );

    setState(() {
      // Filtrer côté client par groupe sanguin pour une meilleure pertinence
      _donneurRecommandes =
          donneurs.where((d) => d['groupeSanguin'] == _selectedgsang).toList();
    });
  }

  Future<void> _createAlerte() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _selectedgsang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_medecinCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Coordonnées GPS non disponibles. Impossible de créer l\'alerte.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = _storage.getUser();
    if (user?.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Utilisateur non trouvé'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final alerteProvider = Provider.of<AlerteProvider>(context, listen: false);

    // Création de l'objet Alerte avec les coordonnées du médecin
    final alerte = Alerte(
      description: _descriptionController.text.trim(),
      gsang: _selectedgsang!,
      // La classe Alerte n'a pas besoin de l'adresse si les coordonnées sont fournies
      // Je mets une adresse par défaut ou vide, car le modèle Alerte la requiert (required this.adresse)
      adresse: "Adresse du Medecin",
      remuneration: double.tryParse(_remunerationController.text) ?? 0,
      medecinId: user!.userId,
      latitude: _medecinCoords!['latitude'],
      longitude: _medecinCoords!['longitude'],
      etat: 'EN_COURS',
    );

    final success = await alerteProvider.createAlerte(alerte);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                    'Alerte créée avec succès ! Les donneurs vont être notifiés.'),
              ),
            ],
          ),
          backgroundColor: AppColors.accent,
          duration: Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Ferme l'écran et envoie 'true' pour indiquer un succès
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(alerteProvider.errorMessage ??
                    'Erreur lors de la création'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        title: const Text(
          'Nouvelle alerte',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingCoords
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des coordonnées du centre...'),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info position
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _medecinCoords != null
                              ? AppColors.accent.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _medecinCoords != null
                                ? AppColors.accent
                                : AppColors.error,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _medecinCoords != null
                                  ? Icons.location_on
                                  : Icons.location_off,
                              color: _medecinCoords != null
                                  ? AppColors.accent
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _medecinCoords != null
                                        ? 'Position de l\'hôpital détectée ✓'
                                        : 'Position de l\'hôpital non disponible',
                                    style: TextStyle(
                                      color: _medecinCoords != null
                                          ? AppColors.accent
                                          : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_medecinCoords != null)
                                    Text(
                                      'Lat: ${_medecinCoords!['latitude']?.toStringAsFixed(4)}, Long: ${_medecinCoords!['longitude']?.toStringAsFixed(4)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_medecinCoords == null)
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _loadMedecinCoordinates,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      CustomTextField(
                        label: 'Description de l\'urgence',
                        hint:
                            'Ex: Accident de la route, besoin urgent de sang...',
                        controller: _descriptionController,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La description est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Groupe sanguin
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Groupe sanguin recherché',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedgsang,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                prefixIcon: Icon(Icons.bloodtype),
                              ),
                              hint:
                                  const Text('Sélectionnez le groupe sanguin'),
                              items: _groupesSanguins.map((groupe) {
                                return DropdownMenuItem(
                                  value: groupe,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          // Assurez-vous que AppColors.bloodGroupColors est défini
                                          color: AppColors
                                                  .bloodGroupColors[groupe] ??
                                              AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(groupe.replaceAll('_', ' ')),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedgsang = value;
                                  // Réinitialiser les recommandations si le groupe sanguin change
                                  _showRecommandations = false;
                                  _donneurRecommandes = [];
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner un groupe sanguin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Rémunération
                      CustomTextField(
                        label: 'Rémunération (FCFA)',
                        hint: '10000',
                        controller: _remunerationController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La rémunération est obligatoire';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount < 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Bouton voir les recommandations
                      if (_medecinCoords != null && _selectedgsang != null)
                        OutlinedButton.icon(
                          onPressed: _showDonneurRecommandes,
                          icon: const Icon(Icons.search),
                          label: Text(
                              'Voir les donneurs ${_selectedgsang!.replaceAll('_', ' ')} disponibles'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                                color: AppColors.secondary, width: 2),
                            foregroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                      if (_showRecommandations) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _donneurRecommandes.isNotEmpty
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _donneurRecommandes.isNotEmpty
                                        ? Icons.people
                                        : Icons.sentiment_dissatisfied,
                                    color: _donneurRecommandes.isNotEmpty
                                        ? AppColors.secondary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_donneurRecommandes.length} donneurs correspondants trouvés',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              if (_donneurRecommandes.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Ces donneurs ${_selectedgsang!.replaceAll('_', ' ')} sont dans un rayon de 5 km et recevront l\'alerte.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              if (_donneurRecommandes.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Aucun donneur de ce groupe sanguin trouvé à proximité (5 km). L\'alerte sera envoyée dès qu\'un donneur se connectera dans la zone.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Les donneurs dans un rayon de 5 km autour de votre hôpital seront notifiés par notification push.',
                                style: TextStyle(
                                  color: AppColors.secondary.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton de création
                      Consumer<AlerteProvider>(
                        builder: (context, alerteProvider, _) {
                          return CustomButton(
                            text: 'Créer l\'alerte',
                            onPressed: _createAlerte,
                            isLoading: alerteProvider.isLoading,
                            icon: Icons.add_alert,
                            backgroundColor: AppColors.primary,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
