import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

/// Boutons d'action pour une gare : localisation (Google Maps, avec lien
/// OpenStreetMap en repli) et appel téléphonique direct.
class GareActions extends StatelessWidget {
  const GareActions({super.key, required this.gare});
  final DepartGare gare;

  Future<void> _openMaps(BuildContext context) async {
    final coords = coordsPour(gare);
    if (coords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position précise non disponible pour cette gare.'),
        ),
      );
      return;
    }
    final (lat, lon) = coords;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openOsm() async {
    final coords = coordsPour(gare);
    if (coords == null) return;
    final (lat, lon) = coords;
    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=17/$lat/$lon',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call() async {
    final digits = gare.telephone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    final phone = digits.startsWith('+') ? digits : '+226$digits';
    await launchUrl(Uri.parse('tel:$phone'));
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = coordsPour(gare) != null;
    final hasPhone = gare.telephone.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            if (hasCoords)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _openMaps(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.map_outlined,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                    label: const Text(
                      'Localiser',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            if (hasCoords && hasPhone) const SizedBox(width: 10),
            if (hasPhone)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: AppColors.buttonGradient,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _call,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.call, color: AppColors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Appeler',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (hasCoords) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: _openOsm,
            child: const Text(
              'Afficher position GPS',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
