class Validators {
    static String? required(String? value) {
        if (value == null || value.trim().isEmpty) {
        return 'Ce champ est obligatoire';
        }
        return null;
    }

    static String? email(String? value) {
        if (value == null || value.trim().isEmpty) {
        return 'L\'email est obligatoire';
        }
        
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
        return 'Email invalide';
        }
        
        return null;
    }

    static String? password(String? value) {
        if (value == null || value.isEmpty) {
        return 'Le mot de passe est obligatoire';
        }
        
        if (value.length < 6) {
        return 'Le mot de passe doit contenir au moins 6 caractères';
        }
        
        return null;
    }

    static String? phone(String? value) {
        if (value == null || value.trim().isEmpty) {
        return null; // Optionnel
        }
        
        final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
        if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
        return 'Numéro de téléphone invalide';
        }
        
        return null;
    }
}