import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/recu_paiement.dart';
import 'package:kmaa_e_tickets/mon-app/tarifs/tarifs.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/dates.dart';

class ConfirmationPaiement extends StatelessWidget {
  const ConfirmationPaiement({super.key, required this.billet});
  final Billet billet;

  Future<void> _download() async {
    final bytes = await buildReceiptPdf(
      compagnieName: billet.compagnie.name,
      depart: billet.depart,
      arrivee: billet.arrivee,
      dateLabel: formatDateFr(billet.dateVoyage),
      heureLabel: billet.heure,
      travelersCount: billet.travelersCount,
      montantLabel: Tarif.format(billet.montantTransport),
      reference: billet.reference,
      validiteLabel:
          'Valable jusqu\'au ${formatDateFr(billet.dateValidite)} (15 jours après achat)',
      qrData: billet.qrData,
      // voyageurLines: [
      //   for (var i = 0; i < billet.voyageurs.length; i++)
      //     '${billet.voyageurs[i]} — code ${billet.codesVoyageurs[i]}',
      // ],
      voyageurLines: [
        for (var i = 0; i < billet.voyageurs.length; i++)
          '${billet.voyageurs[i]} — code ${billet.codesVoyageurs[i]}',
      ],
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'billet-${billet.reference}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Paiement réussi !',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Réf. ${billet.reference}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 28),
                _buildTicket(),
                const SizedBox(height: 28),
                _buildActionButton(
                  label: 'Télécharger mon billet',
                  icon: Icons.download_outlined,
                  filled: true,
                  onTap: _download,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  label: "Retour à l'accueil",
                  icon: Icons.home_outlined,
                  filled: false,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicket() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: billet.compagnie.image == null
                          ? const Icon(
                              Icons.directions_bus_rounded,
                              color: AppColors.secondary,
                              size: 22,
                            )
                          : Image.asset(
                              billet.compagnie.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.directions_bus_rounded,
                                color: AppColors.secondary,
                                size: 22,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            billet.compagnie.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const Text(
                            'Billet de transport',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildRow(
                  'Départ',
                  billet.depart.isEmpty ? '—' : billet.depart,
                ),
                _buildRow(
                  'Arrivée',
                  billet.arrivee.isEmpty ? '—' : billet.arrivee,
                ),
                _buildRow('Date', formatDateFr(billet.dateVoyage)),
                _buildRow('Heure', billet.heure),
                _buildRow('Paiement', billet.operateur.name),
                const SizedBox(height: 14),
                _buildVoyageurs(),
              ],
            ),
          ),
          Row(
            children: List.generate(
              28,
              (i) => Expanded(
                child: Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: i.isEven ? AppColors.border : Colors.transparent,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prix du transport',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  Tarif.format(billet.montantTransport),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Valable jusqu\'au ${formatDateFr(billet.dateValidite)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: billet.qrData,
                    size: 140,
                    backgroundColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scannez pour vérifier ce billet',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoyageurs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voyageurs et codes de vérification',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < billet.voyageurs.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    billet.voyageurs[i],
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    billet.codesVoyageurs[i],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final radius = BorderRadius.circular(8);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: filled ? AppColors.buttonGradient : null,
          border: filled ? null : Border.all(color: AppColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: filled ? AppColors.white : AppColors.textDark,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: filled ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
