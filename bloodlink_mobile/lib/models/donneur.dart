import 'user.dart';

class Donneur extends User {
    final String groupeSanguin;
    final double? latitude;
    final double? longitude;
    final double solde;

    Donneur({
        required super.userId,
        required super.email,
        required super.nom,
        super.sexe,
        super.numero,
        required super.role,
        required this.groupeSanguin,
        this.latitude,
        this.longitude,
        this.solde = 0.0,
    });

    factory Donneur.fromJson(Map<String, dynamic> json) {
        return Donneur(
        userId: json['userId'],
        email: json['email'],
        nom: json['nom'] ?? '',
        sexe: json['sexe'],
        numero: json['numero'],
        role: json['role'],
        groupeSanguin: json['gsang'] ?? 'O_PLUS',
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        solde: json['solde']?.toDouble() ?? 0.0,
        );
    }

    @override
    Map<String, dynamic> toJson() {
        return {
        ...super.toJson(),
        'gsang': groupeSanguin,
        'latitude': latitude,
        'longitude': longitude,
        'solde': solde,
        };
    }
}