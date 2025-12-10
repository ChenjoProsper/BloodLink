import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/alerte.dart';
import '../../providers/location_provider.dart';
import '../../providers/alerte_provider.dart';
import '../../core/services/medecin_service.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/custom_button.dart';

class AlerteDetailsScreen extends StatefulWidget {
  final Alerte alerte;

  const AlerteDetailsScreen({
    Key? key,
    required this.alerte,
  }) : super(key: key);

  @override
  State<AlerteDetailsScreen> createState() => _AlerteDetailsScreenState();
}

class _AlerteDetailsScreenState extends State<AlerteDetailsScreen> {
  final _medecinService = MedecinService();
  final _storage = StorageService();
  GoogleMapController? _mapController;
  Map<String, double>? _medecinCoords;
  bool _isLoadingCoords = true;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _loadMedecinCoordinates();
  }

  Future<void> _loadMedecinCoordinates() async {
    setState(() {
      _isLoadingCoords = true;
    });

    // Récupérer les coordonnées du médecin
    final coords = await _medecinService.getCoordonnesByMedecinId(
      widget.alerte.medecinId,
    );

    setState(() {
      _medecinCoords = coords;
      _isLoadingCoords = false;
    });
  }

  Future<void> _accepterAlerte() async {
    setState(() {
      _isAccepting = true;
    });

    final user = _storage.getUser();
    if (user?.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Utilisateur non trouvé'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() {
        _isAccepting = false;
      });
      return;
    }

    final alerteProvider = Provider.of<AlerteProvider>(context, listen: false);

    final result = await alerteProvider.accepterAlerte(
      widget.alerte.alerteId!,
      user!.userId,
    );

    setState(() {
      _isAccepting = false;
    });

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Alerte acceptée ! L\'hôpital a été notifié.'),
              ),
            ],
          ),
          backgroundColor: AppColors.accent,
        ),
      );

      // Afficher dialog pour ouvrir Maps
      _showNavigationDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showNavigationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.directions, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Navigation'),
          ],
        ),
        content: const Text(
          'Voulez-vous ouvrir Google Maps pour vous rendre à l\'hôpital ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Plus tard'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _openGoogleMaps();
            },
            icon: const Icon(Icons.map),
            label: const Text('Ouvrir Maps'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    if (_medecinCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coordonnées de l\'hôpital non disponibles'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final lat = _medecinCoords!['latitude'];
    final lon = _medecinCoords!['longitude'];

    // URL pour Google Maps
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir Google Maps'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    double? distance;

    if (widget.alerte.latitude != null &&
        widget.alerte.longitude != null &&
        locationProvider.currentPosition != null) {
      distance = locationProvider.calculateDistanceToAlerte(
        widget.alerte.latitude!,
        widget.alerte.longitude!,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Détails de l\'alerte'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte
            if (_isLoadingCoords)
              Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_medecinCoords != null &&
                locationProvider.currentPosition != null)
              SizedBox(
                height: 250,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      locationProvider.currentPosition!.latitude,
                      locationProvider.currentPosition!.longitude,
                    ),
                    zoom: 13,
                  ),
                  markers: {
                    // Marker du donneur
                    Marker(
                      markerId: const MarkerId('donneur'),
                      position: LatLng(
                        locationProvider.currentPosition!.latitude,
                        locationProvider.currentPosition!.longitude,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                      infoWindow: const InfoWindow(title: 'Votre position'),
                    ),
                    // Marker de l'hôpital
                    Marker(
                      markerId: const MarkerId('hopital'),
                      position: LatLng(
                        _medecinCoords!['latitude']!,
                        _medecinCoords!['longitude']!,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: const InfoWindow(title: 'Hôpital'),
                    ),
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(
                  child: Text('Carte non disponible'),
                ),
              ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge groupe sanguin
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bloodGroupColors[widget.alerte.gsang] ??
                          AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.alerte.gsang.replaceAll('_', ' '),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.alerte.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Infos
                  _buildInfoCard(
                    icon: Icons.payments,
                    title: 'Rémunération',
                    value:
                        '${widget.alerte.remuneration!.toStringAsFixed(0)} FCFA',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),

                  if (distance != null)
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Distance',
                      value: '${distance.toStringAsFixed(1)} km',
                      color: AppColors.secondary,
                    ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.flag,
                    title: 'État',
                    value: widget.alerte.etat,
                    color: _getEtatColor(widget.alerte.etat),
                  ),
                  const SizedBox(height: 32),

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Refuser'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                                color: AppColors.error, width: 2),
                            foregroundColor: AppColors.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: 'Accepter',
                          onPressed: widget.alerte.etat == 'EN_COURS'
                              ? () {
                                  _accepterAlerte();
                                }
                              : () {},
                          isLoading: _isAccepting,
                          icon: Icons.check,
                          backgroundColor: AppColors.accent,
                        ),
                      ),
                    ],
                  ),

                  if (widget.alerte.etat != 'EN_COURS') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cette alerte n\'est plus active',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
