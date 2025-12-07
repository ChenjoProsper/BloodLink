class Alerte {
    final String? alerteId;
    final String description;
    final String groupeSanguin;
    final double remuneration;
    final String medecinId;
    final double? latitude;
    final double? longitude;
    final String etat; // EN_COURS, TERMINER, ANNULER
    final DateTime? createdAt;

    Alerte({
        this.alerteId,
        required this.description,
        required this.groupeSanguin,
        required this.remuneration,
        required this.medecinId,
        this.latitude,
        this.longitude,
        this.etat = 'EN_COURS',
        this.createdAt,
    });

    factory Alerte.fromJson(Map<String, dynamic> json) {
        return Alerte(
        alerteId: json['alerteId'],
        description: json['description'],
        groupeSanguin: json['groupeSanguin'] ?? json['gsang'],
        remuneration: json['remuneration']?.toDouble() ?? 0.0,
        medecinId: json['medecinId'],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        etat: json['etat'] ?? 'EN_COURS',
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : null,
        );
    }

    Map<String, dynamic> toJson() {
        return {
        if (alerteId != null) 'alerteId': alerteId,
        'description': description,
        'groupeSanguin': groupeSanguin,
        'remuneration': remuneration,
        'medecinId': medecinId,
        'latitude': latitude,
        'longitude': longitude,
        'etat': etat,
        };
    }
}