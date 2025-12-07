import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/alerte_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
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

    String? _selectedGroupeSanguin;

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
    void dispose() {
        _descriptionController.dispose();
        _remunerationController.dispose();
        super.dispose();
    }

    Future<void> _createAlerte() async {
        if (!_formKey.currentState!.validate() || _selectedGroupeSanguin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Veuillez remplir tous les champs'),
            backgroundColor: AppColors.error,
            ),
        );
        return;
        }

        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        await locationProvider.getCurrentPosition();

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final alerteProvider = Provider.of<AlerteProvider>(context, listen: false);

        // TODO: Récupérer le vrai ID du médecin
        final alerte = Alerte(
        description: _descriptionController.text.trim(),
        groupeSanguin: _selectedGroupeSanguin!,
        remuneration: double.tryParse(_remunerationController.text) ?? 0,
        medecinId: 'medecin-id', // À remplacer par le vrai ID
        latitude: locationProvider.currentPosition?.latitude,
        longitude: locationProvider.currentPosition?.longitude,
        );

        final success = await alerteProvider.createAlerte(alerte);

        if (!mounted) return;

        if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Alerte créée avec succès'),
            backgroundColor: AppColors.accent,
            ),
        );
        Navigator.pop(context);
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(alerteProvider.errorMessage ?? 'Erreur'),
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
        body: SafeArea(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
                key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    // Description
                    CustomTextField(
                    label: 'Description de l\'urgence',
                    hint: 'Ex: Accident de la route, besoin urgent...',
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
                        const Text(
                        'Groupe sanguin recherché',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                        ),
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
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            prefixIcon: Icon(Icons.bloodtype),
                            ),
                            hint: const Text('Sélectionnez le groupe sanguin'),
                            items: _groupesSanguins.map((groupe) {
                            return DropdownMenuItem(
                                value: groupe,
                                child: Text(groupe.replaceAll('_', ' ')),
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
                    const SizedBox(height: 32),

                    // Info rayon
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
                            'Les donneurs dans un rayon de 5 km seront notifiés',
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
