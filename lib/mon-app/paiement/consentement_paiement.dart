import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/service_client/service_client.dart';

/// Avertissement, consentement et bouton de paiement : le bouton reste grisé
/// tant que le client n'a pas coché la case.
class BlocConsentementPaiement extends StatefulWidget {
  const BlocConsentementPaiement({
    super.key,
    required this.libelleBouton,
    required this.onPay,
  });

  final String libelleBouton;
  final VoidCallback onPay;

  @override
  State<BlocConsentementPaiement> createState() =>
      _BlocConsentementPaiementState();
}

class _BlocConsentementPaiementState extends State<BlocConsentementPaiement> {
  bool _accepte = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AvertissementFrais(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _accepte,
                activeColor: AppColors.secondary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) => setState(() => _accepte = v ?? false),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Je reconnais avoir lu et pris connaissance des conditions d\'utilisation et de la '
                'politique de confidentialité. J\'accepte que mes données personnelles soient utilisées '
                'pour la réservation, l\'émission et le contrôle de mes billets. Je confirme que les noms '
                'des voyageurs sont exacts et je reconnais que tout frais payé est non remboursables.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textDark,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ConditionsScreen())),
            child: const Text(
              'Lire les conditions et la politique de confidentialité',
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: _accepte ? AppColors.buttonGradient : null,
              color: _accepte ? null : AppColors.border,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: radius,
                onTap: _accepte ? widget.onPay : null,
                child: Center(
                  child: Text(
                    widget.libelleBouton,
                    style: TextStyle(
                      color: _accepte ? AppColors.white : AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Encadré d'attention sur les frais non remboursables.
class AvertissementFrais extends StatelessWidget {
  const AvertissementFrais({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Attention : tout frais payé est non remboursable.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Texte complet des conditions et de la politique de confidentialité.
class ConditionsScreen extends StatelessWidget {
  const ConditionsScreen({super.key});

  static const _sections = <(String, String, IconData)>[
    (
      'Objet',
      'L\'application permet de réserver et de payer des billets de transport auprès de compagnies '
          'partenaires. Converge SAS en est l\'éditeur.',
      Icons.confirmation_number_outlined,
    ),
    (
      'Frais de service',
      'Chaque achat donne lieu à des frais de service de 300 FCFA, payés une seule fois quel que soit '
          'le nombre de billets. Tout frais payé est non remboursable.',
      Icons.payments_outlined,
    ),
    (
      'Votre billet',
      'Le billet est utilisable à partir du jour du voyage choisi, jusqu\'à 12 jours après l\'achat '
          '. Vous pouvez reporter votre voyage, sans '
          'avoir à vous justifier, vers un autre départ de la même route dans cette durée. Un billet'
          'déjà utilisé pour embarquer ne peut plus être ni utilisé '
          'ni reporté.',
      Icons.directions_bus_outlined,
    ),
    (
      'Annulation et remboursement',
      'Les conditions d\'annulation et de remboursement du prix du billet sont fixées par chaque '
          'compagnie. Les frais de service ne sont pas remboursables.',
      Icons.event_busy_outlined,
    ),
    // (
    //   'Exactitude des informations',
    //   'Vous vous engagez à indiquer des noms de voyageurs exacts : ils figurent sur la liste remise à la '
    //       'compagnie pour le départ.',
    //   Icons.fact_check_outlined,
    // ),
    (
      'Exactitude des informations',
      'Le renseignement des noms des autres voyageurs est facultatif. Si vous choisissez de les indiquer,'
          'veillez à leur exactitude, car ces informations peuvent être transmises à la compagnie pour organiser le départ.',
      Icons.fact_check_outlined,
    ),
    (
      'Vos données personnelles',
      'Nous collectons votre nom, votre prénom, votre numéro de téléphone, vos billets, vos paiements et '
          'vos avis. Ces données servent à la réservation, à l\'émission et au contrôle des billets, aux '
          'notifications, à l\'assistance, à la prévention de la fraude et à des statistiques. La compagnie '
          'concernée reçoit la liste des voyageurs de ses départs (nom et code du billet). Nous ne vendons '
          'pas vos données. Elles sont conservées le temps de la relation avec vous et selon nos obligations '
          'légales, et protégées par des moyens techniques adaptés. Vous pouvez demander l\'accès, la '
          'rectification ou la suppression de vos données, ou vous opposer à leur traitement, en contactant '
          'le service client.',
      Icons.shield_outlined,
    ),
    (
      'Contact',
      'Service client : $kServiceClientAffichage.',
      Icons.support_agent_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Conditions et confidentialité',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voyagez en toute confiance',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Prenez un instant pour consulter les conditions de réservation et la façon dont vos données sont protégées.',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.6),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vos informations sont utilisées pour gérer votre réservation et vous accompagner.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'À connaître avant votre réservation',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          for (var i = 0; i < _sections.length; i++) ...[
            _buildSectionCard(i, _sections[i]),
            if (i < _sections.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryDark,
                  size: 17,
                ),
                SizedBox(width: 8),
                Text(
                  'Version 1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(int index, (String, String, IconData) section) {
    final (titre, texte, icone) = section;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icone, color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            texte,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
