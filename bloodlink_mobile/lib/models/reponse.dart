import 'alerte.dart';
import 'donneur.dart';

class Reponse {
  final String reponseId;
  final Alerte alerte;
  final Donneur donneur;
  final DateTime dateReponse;
  final String statut;

  Reponse({
    required this.reponseId,
    required this.alerte,
    required this.donneur,
    required this.dateReponse,
    required this.statut,
  });

  // Cette méthode n'est plus critique si elle n'est pas utilisée par le service qui crashait,
  // mais elle est rendue plus robuste pour les autres appels API.
  factory Reponse.fromJson(Map<String, dynamic> json) {
    return Reponse(
      reponseId: json['reponseId'] as String? ?? '',
      // Fournit un objet vide pour éviter le crash si 'alerte' ou 'donneur' sont null
      alerte: Alerte.fromJson(json['alerte'] ?? {}),
      donneur: Donneur.fromJson(json['donneur'] ?? {}),
      dateReponse: json['dateReponse'] != null
          ? DateTime.tryParse(json['dateReponse']!) ?? DateTime.now()
          : DateTime.now(),
      statut: json['statut'] as String? ?? 'EN_ATTENTE',
    );
  }
}
