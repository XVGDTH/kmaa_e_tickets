import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/billet/reporter_billet.dart';
import 'package:kmaa_e_tickets/mon-app/localisation_gares/localisation_gares.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/formulaire_notation.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/notation_gares.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/recu_paiement.dart';
import 'package:kmaa_e_tickets/mon-app/tarifs/tarifs.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/dates.dart';

class BilletDetail extends StatelessWidget {
  const BilletDetail({super.key, required this.billet});

  final Billet billet;

  Future<void> _download() async {
    final bytes = await buildReceiptPdf(
      compagnieName: billet.compagnie.name,
      depart: billet.depart,
      arrivee: billet.arrivee,
      dateLabel: formatDateFr(billet.dateVoyage),
      heureLabel: formatHeure(billet.heure),
      travelersCount: billet.travelersCount,
      montantLabel: Tarif.format(billet.montantTransport),
      reference: billet.reference,
      validiteLabel:
          // 'Valable jusqu\'au ${formatDateFr(billet.dateValidite)} (15 jours après achat)',
          'Valable jusqu\'au ${formatDateFr(billet.dateValidite)}',
      qrData: billet.qrData,
      // voyageurLines: billet.voyageurs,
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Mon billet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTicket(),
                const SizedBox(height: 20),
                //logique de notation lorsque le voyage se termine
                // if (!billet.estAVenir && billet.gare != null) ...[
                if (billet.peutEtreNote && billet.gare != null) ...[
                  _buildRateButton(context),
                  const SizedBox(height: 12),
                ],
                if (billet.peutEtreReporte) ...[
                  _buildReportButton(context),
                  const SizedBox(height: 12),
                ],
                // logique du button telecharger le recu
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: AppColors.buttonGradient,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _download,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_outlined,
                              color: AppColors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Télécharger le reçu',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
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
                          color: AppColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Réf. ${billet.reference}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    billet.statutLabel,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildRow(
                  'Départ',
                  billet.depart.isEmpty ? '—' : billet.depart,
                ),
                _buildRow(
                  'Arrivée',
                  billet.arrivee.isEmpty ? '—' : billet.arrivee,
                ),
                _buildRow('Date', formatDateFr(billet.dateVoyage)),
                _buildRow('Heure', formatHeure(billet.heure)),
                _buildRow('Voyageurs', '${billet.travelersCount}'),
                _buildRow('Paiement', billet.operateur.name),
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
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
                if (billet.gare != null) ...[
                  const Divider(height: 1, color: AppColors.border),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                billet.gare!.quartier,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (billet.gare!.adresse.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            billet.gare!.adresse,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Durée max estimée : ${billet.gare!.dureeMax}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GareActions(gare: billet.gare!),
                      ],
                    ),
                  ),
                ],
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

  // widget de notation de la compagnie
  Widget _buildRateButton(BuildContext context) {
    // final deja = AvisGareStore.instance.dejaNote(billet.reference);
    final deja =
        billet.aAvis || AvisGareStore.instance.dejaNote(billet.reference);
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: deja
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NotationGareScreen(billet: billet),
                ),
              ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: deja ? AppColors.border : AppColors.secondary,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(
          deja ? Icons.check_circle_outline : Icons.star_border_rounded,
          color: deja ? AppColors.textMuted : AppColors.secondary,
          size: 18,
        ),
        label: Text(
          deja ? 'Avis déjà envoyé' : 'Noter cette gare',
          style: TextStyle(
            color: deja ? AppColors.textMuted : AppColors.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          final reporte = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ReporterBilletScreen(billet: billet),
            ),
          );
          // Le billet a changé de date : on revient à « Mes billets », qui est à jour.
          if (reporte == true && context.mounted) Navigator.of(context).pop();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(
          Icons.event_repeat_rounded,
          color: AppColors.secondary,
          size: 18,
        ),
        label: const Text(
          'Reporter mon voyage',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
