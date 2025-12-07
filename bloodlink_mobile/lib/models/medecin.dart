import 'user.dart';

class Medecin extends User {
  final String adresse;

  Medecin({
    required super.userId,
    required super.email,
    required super.nom,
    super.sexe,
    super.numero,
    required super.role,
    required this.adresse,
  });

  factory Medecin.fromJson(Map<String, dynamic> json) {
    return Medecin(
      userId: json['userId'],
      email: json['email'],
      nom: json['nom'] ?? '',
      sexe: json['sexe'],
      numero: json['numero'],
      role: json['role'],
      adresse: json['adresse'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'adresse': adresse,
    };
  }
}
