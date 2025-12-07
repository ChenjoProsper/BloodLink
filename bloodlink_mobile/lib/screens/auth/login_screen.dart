import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
    const LoginScreen({Key? key}) : super(key: key);

    @override
    State<LoginScreen> createState() => _LoginScreenState();
    }

    class _LoginScreenState extends State<LoginScreen> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _obscurePassword = true;

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        super.dispose();
    }

    Future<void> _login() async {
        if (!_formKey.currentState!.validate()) return;

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        );

        if (!mounted) return;

        if (success) {
        final role = authProvider.currentUser?.role;
        if (role == 'DONNEUR') {
            Navigator.pushReplacementNamed(context, '/donneur/home');
        } else if (role == 'MEDECIN') {
            Navigator.pushReplacementNamed(context, '/medecin/home');
        }
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erreur de connexion'),
            backgroundColor: AppColors.error,
            ),
        );
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
                key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    const SizedBox(height: 40),
                    
                    // Logo
                    Center(
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                            BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            ),
                        ],
                        ),
                        child: const Icon(
                        Icons.bloodtype,
                        size: 60,
                        color: Colors.white,
                        ),
                    ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Text(
                    'Connexion',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    const Text(
                    'Connectez-vous pour continuer',
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
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
                    validator: Validators.required,
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton de connexion
                    Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                        return CustomButton(
                        text: 'Se connecter',
                        onPressed: _login,
                        isLoading: authProvider.isLoading,
                        icon: Icons.login,
                        );
                    },
                    ),
                    const SizedBox(height: 24),
                    
                    // Lien vers l'inscription
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text(
                        'Pas encore de compte ? ',
                        style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                        onPressed: () {
                            Navigator.pushNamed(context, '/register/choice');
                        },
                        child: const Text(
                            'S\'inscrire',
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