import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/alerte.dart';

class AlerteCard extends StatelessWidget {
    final Alerte alerte;
    final VoidCallback? onTap;
    final VoidCallback? onAccept;
    final VoidCallback? onRefuse;
    final double? distance;

    const AlerteCard({
        Key? key,
        required this.alerte,
        this.onTap,
        this.onAccept,
        this.onRefuse,
        this.distance,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header avec groupe sanguin
                Row(
                    children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                        ),
                        decoration: BoxDecoration(
                        color: AppColors.bloodGroupColors[alerte.groupeSanguin] ??
                            AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                        alerte.groupeSanguin.replaceAll('_', ' '),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                        ),
                        ),
                    ),
                    const Spacer(),
                    if (distance != null)
                        Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                        ),
                        decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                            children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text(
                                '${distance!.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                ),
                            ),
                            ],
                        ),
                        ),
                    ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                    alerte.description,
                    style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    ),
                ),
                const SizedBox(height: 8),

                // Rémunération
                if (alerte.remuneration > 0)
                    Row(
                    children: [
                        const Icon(Icons.payments, size: 18, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                        '${alerte.remuneration.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                        ),
                        ),
                    ],
                    ),
                const SizedBox(height: 12),

                // État
                Container(
                    padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                    ),
                    decoration: BoxDecoration(
                    color: _getEtatColor(alerte.etat).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                    alerte.etat,
                    style: TextStyle(
                        color: _getEtatColor(alerte.etat),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                    ),
                    ),
                ),

                // Boutons d'action (si fournis)
                if (onAccept != null || onRefuse != null) ...[
                    const SizedBox(height: 12),
                    Row(
                    children: [
                        if (onRefuse != null)
                        Expanded(
                            child: OutlinedButton(
                            onPressed: onRefuse,
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                ),
                            ),
                            child: const Text('Refuser'),
                            ),
                        ),
                        if (onAccept != null && onRefuse != null)
                        const SizedBox(width: 12),
                        if (onAccept != null)
                        Expanded(
                            child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                ),
                            ),
                            child: const Text('Accepter'),
                            ),
                        ),
                    ],
                    ),
                ],
                ],
            ),
            ),
        ),
        );
    }

    Color _getEtatColor(String etat) {
        switch (etat) {
        case 'EN_COURS':
            return AppColors.accent;
        case 'TERMINER':
            return Colors.grey;
        case 'ANNULER':
            return AppColors.error;
        default:
            return AppColors.textSecondary;
        }
    }
}