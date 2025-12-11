// Fichier: models/alerte.dart (VERSION FINALE)

class Alerte {
  final String? alerteId;
  final String? description;
  final String gsang;
  final String adresse;
  final double? remuneration;
  final String medecinId;
  final String etat;
  final DateTime? createdAt;
  // 💡 AJOUT : Coordonnées pour le calcul de distance dans DonneurHomeScreen
  final double? latitude;
  final double? longitude;

  Alerte({
    this.alerteId,
    this.description,
    required this.gsang,
    required this.adresse,
    this.remuneration,
    required this.medecinId,
    this.etat = 'EN_COURS',
    this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory Alerte.fromJson(Map<String, dynamic> json) {
    return Alerte(
      alerteId: json['alerteId']?.toString() ?? json['id']?.toString(),
      description: json['description'] ?? 'Description manquante',
      gsang: json['gsang'] ?? 'O_PLUS',
      adresse: json['adresse'] ?? 'Adresse non spécifiée',
      remuneration: (json['remuneration'] as num?)?.toDouble() ?? 0.0,
      medecinId: json['medecinId']?.toString() ?? '',
      etat: json['etat'] ?? 'EN_COURS',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      // NOUVEAU MAPPAGE
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (alerteId != null) 'alerteId': alerteId,
      'description': description,
      'gsang': gsang,
      'adresse': adresse,
      'remuneration': remuneration,
      'medecinId': medecinId,
      'etat': etat,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
