import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/alerte_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
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

  String? _selectedGroupeSanguin;
  Map<String, double>? _medecinCoords;
  List<dynamic> _donneurRecommandes = [];
  bool _isLoadingCoords = false;
  bool _showRecommandations = false;

  final List<String> _groupesSanguins = [
    'A_PLUS',
    'A_MINUS',
    'B_PLUS',
    'B_MINUS',
    'AB_PLUS',
    'AB_MINUS',
    'O_PLUS',
    'O_MINUS',
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
      final coords =
          await _medecinService.getCoordonnesByMedecinId(user!.userId);

      if (coords != null) {
        setState(() {
          _medecinCoords = coords;
        });
      } else {
        // Essayer de récupérer par adresse si l'ID ne fonctionne pas
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Coordonnées GPS non disponibles. Veuillez vérifier votre adresse.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() {
      _isLoadingCoords = false;
    });
  }

  /// Afficher les donneurs recommandés
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

    setState(() {
      _showRecommandations = true;
    });

    final alerteProvider = Provider.of<AlerteProvider>(context, listen: false);

    final donneurs = await alerteProvider.getRecommendations(
      _medecinCoords!['latitude']!,
      _medecinCoords!['longitude']!,
    );

    setState(() {
      _donneurRecommandes = donneurs;
    });
  }

  Future<void> _createAlerte() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _selectedGroupeSanguin == null) {
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

    final alerte = Alerte(
      description: _descriptionController.text.trim(),
      groupeSanguin: _selectedGroupeSanguin!,
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
        title: const Text('Nouvelle alerte'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingCoords
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des coordonnées...'),
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
                                      'Rayon de recherche: 5 km',
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
                              value: _selectedGroupeSanguin,
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
                                  _selectedGroupeSanguin = value;
                                });
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
                      if (_medecinCoords != null)
                        OutlinedButton.icon(
                          onPressed: _showDonneurRecommandes,
                          icon: const Icon(Icons.search),
                          label: const Text('Voir les donneurs disponibles'),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_donneurRecommandes.length} donneurs trouvés',
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
                                  'Dans un rayon de 5 km',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
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
