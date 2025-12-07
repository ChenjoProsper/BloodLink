class User {
  final String userId;
  final String email;
  final String nom;
  final String? sexe;
  final String? numero;
  final String role;

  User({
    required this.userId,
    required this.email,
    required this.nom,
    this.sexe,
    this.numero,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      nom: json['nom'] ?? '',
      sexe: json['sexe'],
      numero: json['numero'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'nom': nom,
      'sexe': sexe,
      'numero': numero,
      'role': role,
    };
  }
}
