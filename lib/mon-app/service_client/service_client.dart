import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:url_launcher/url_launcher.dart';

const String kServiceClientAffichage = '54 78 55 55';
const String kServiceClientTelephone = '+22654785555';

/// Jours et heures d'écoute, par exemple 'Du lundi au samedi, de 8h à 18h'.
/// Laisse vide tant que tu ne les as pas fixés : la ligne n'est alors pas affichée.
const String kServiceClientHoraires = '';

class ServiceClientScreen extends StatelessWidget {
  const ServiceClientScreen({super.key, this.referenceBillet});

  /// Référence du billet concerné, à communiquer au conseiller.
  final String? referenceBillet;

  Future<void> _appeler(BuildContext context) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri(scheme: 'tel', path: kServiceClientTelephone));
    } catch (_) {}

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d\'ouvrir le composeur. Composez le $kServiceClientAffichage.',
          ),
        ),
      );
    }
  }

  Future<void> _copier(
    BuildContext context,
    String texte,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: texte));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text(
          'Service client',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.headset_mic_rounded,
                    color: AppColors.secondary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Nous sommes à votre écoute',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Une question, un souci avec un billet ou un paiement ? Appelez-nous.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.white, fontSize: 13),
                ),
                if (kServiceClientHoraires.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    kServiceClientHoraires,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _appeler(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.call_rounded),
              label: const Text(
                'Appeler le $kServiceClientAffichage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  _copier(context, kServiceClientAffichage, 'Numéro copié.'),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copier le numéro'),
            ),
          ),
          if (referenceBillet != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Donnez cette référence au conseiller :\n$referenceBillet',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _copier(context, referenceBillet!, 'Référence copiée.'),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          const Text(
            'Appelez-nous pour',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          for (final motif in const [
            'Un problème de paiement ou de billet introuvable',
            'Reporter ou annuler un voyage',
            'Une réclamation sur un voyage ou une gare',
            'Toute question sur l\'application',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      motif,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          const Text(
            'Une assistance en ligne arrivera prochainement.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
