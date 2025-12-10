class Alerte {
  final String? alerteId;
  final String? description;
  final String gsang;
  final double? remuneration;
  final String medecinId;
  final double? latitude;
  final double? longitude;
  final String etat; // EN_COURS, TERMINER, ANNULER
  final DateTime? createdAt;

  Alerte({
    this.alerteId,
    this.description,
    required this.gsang,
    this.remuneration,
    required this.medecinId,
    this.latitude,
    this.longitude,
    this.etat = 'EN_COURS',
    this.createdAt,
  });

  factory Alerte.fromJson(Map<String, dynamic> json) {
    return Alerte(
      alerteId: json['alerteId']?.toString(),
      description: json['description'] ?? '',
      gsang: json['gsang'] ?? json['gsang'] ?? 'O_PLUS',
      remuneration: (json['remuneration'] ?? 0).toDouble(),
      medecinId: json['medecinId']?.toString() ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      etat: json['etat'] ?? 'EN_COURS',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (alerteId != null) 'alerteId': alerteId,
      'description': description,
      'gsang': gsang,
      'remuneration': remuneration,
      'medecinId': medecinId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'etat': etat,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
