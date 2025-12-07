import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';

class RegisterDonneurScreen extends StatefulWidget {
    const RegisterDonneurScreen({Key? key}) : super(key: key);

    @override
    State<RegisterDonneurScreen> createState() => _RegisterDonneurScreenState();
    }

    class _RegisterDonneurScreenState extends State<RegisterDonneurScreen> {
    final _formKey = GlobalKey<FormState>();
    final _nomController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _numeroController = TextEditingController();
    
    String? _selectedSexe;
    String? _selectedGroupeSanguin;
    bool _obscurePassword = true;

    final List<String> _sexes = ['M', 'F'];
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
        _nomController.dispose();
        _emailController.dispose();
        _passwordController.dispose();
        _numeroController.dispose();
        super.dispose();
    }

    Future<void> _register() async {
        if (!_formKey.currentState!.validate()) return;

        if (_selectedGroupeSanguin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
            content: Text('Veuillez sélectionner votre groupe sanguin'),
            backgroundColor: AppColors.error,
            ),
        );
        return;
        }

        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        await locationProvider.getCurrentPosition();

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final success = await authProvider.registerDonneur(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nom: _nomController.text.trim(),
        sexe: _selectedSexe,
        groupeSanguin: _selectedGroupeSanguin!,
        latitude: locationProvider.currentPosition?.latitude,
        longitude: locationProvider.currentPosition?.longitude,
        numero: _numeroController.text.trim(),
        );

        if (!mounted) return;

        if (success) {
        Navigator.pushReplacementNamed(context, '/donneur/home');
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erreur d\'inscription'),
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Inscription Donneur'),
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
                key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    // Nom
                    CustomTextField(
                    label: 'Nom complet',
                    hint: 'Jean Dupont',
                    controller: _nomController,
                    prefixIcon: Icons.person_outlined,
                    validator: Validators.required,
                    ),
                    const SizedBox(height: 20),
                    
                    // Email
                    CustomTextField(
                    label: 'Email',
                    hint: 'exemple@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.email,
                    ),
                    const SizedBox(height: 20),
                    
                    // Password
                    CustomTextField(
                    label: 'Mot de passe',
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                        icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                        setState(() {
                            _obscurePassword = !_obscurePassword;
                        });
                        },
                    ),
                    validator: Validators.password,
                    ),
                    const SizedBox(height: 20),
                    
                    // Numéro
                    CustomTextField(
                    label: 'Numéro de téléphone',
                    hint: '+237 600 00 00 00',
                    controller: _numeroController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 20),
                    
                    // Sexe
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                        'Sexe',
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
                            value: _selectedSexe,
                            decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            prefixIcon: Icon(Icons.people_outlined),
                            ),
                            hint: const Text('Sélectionnez'),
                            items: _sexes.map((sexe) {
                            return DropdownMenuItem(
                                value: sexe,
                                child: Text(sexe == 'M' ? 'Masculin' : 'Féminin'),
                            );
                            }).toList(),
                            onChanged: (value) {
                            setState(() {
                                _selectedSexe = value;
                            });
                            },
                        ),
                        ),
                    ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Groupe sanguin
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                        'Groupe sanguin',
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
                            hint: const Text('Sélectionnez votre groupe sanguin'),
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
                    const SizedBox(height: 32),
                    
                    // Bouton d'inscription
                    Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                        return CustomButton(
                        text: 'S\'inscrire',
                        onPressed: _register,
                        isLoading: authProvider.isLoading,
                        icon: Icons.person_add,
                        );
                    },
                    ),
                    const SizedBox(height: 16),
                    
                    // Lien vers connexion
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text(
                        'Déjà un compte ? ',
                        style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                        onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                        },
                        child: const Text(
                            'Se connecter',
                            style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            ),
                        ),
                        ),
                    ],
                    ),
                ],
                ),
            ),
            ),
        ),
        );
    }
}