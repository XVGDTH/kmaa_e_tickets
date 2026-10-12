import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/billet/detail_billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/recu_paiement.dart';
import 'package:kmaa_e_tickets/mon-app/tarifs/tarifs.dart';
import 'package:printing/printing.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/dates.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/menu.dart';

class MesBillets extends StatefulWidget {
  const MesBillets({super.key});

  @override
  State<MesBillets> createState() => _MesBilletsState();
}

class _MesBilletsState extends State<MesBillets> {
  int _tab = 0; // 0 = à venir, 1 = historique

  void _onMenuSelect(MenuItem item) =>
      AppRoutes.navigateFromMenu(context, item);

  Future<void> _download(Billet b) async {
    final bytes = await buildReceiptPdf(
      compagnieName: b.compagnie.name,
      depart: b.depart,
      arrivee: b.arrivee,
      dateLabel: formatDateFr(b.dateVoyage),
      heureLabel: formatHeure(b.heure),
      travelersCount: b.travelersCount,
      montantLabel: Tarif.format(b.montantTransport),
      reference: b.reference,
      validiteLabel:
          'Valable jusqu\'au ${formatDateFr(b.dateValidite)} (15 jours après achat)',
      qrData: b.qrData,
      // voyageurLines: b.voyageurs,
      voyageurLines: [
        for (var i = 0; i < b.voyageurs.length; i++)
          '${b.voyageurs[i]} — code ${b.codesVoyageurs[i]}',
      ],
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'billet-${b.reference}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ValueListenableBuilder<List<Billet>>(
            valueListenable: TicketStore.instance.billets,
            builder: (context, all, _) {
              final aVenir = all.where((b) => b.estAVenir).toList()
                ..sort(
                  (a, c) => a.dateHeureVoyage.compareTo(c.dateHeureVoyage),
                );
              final historique = all.where((b) => !b.estAVenir).toList()
                ..sort(
                  (a, c) => c.dateHeureVoyage.compareTo(a.dateHeureVoyage),
                );
              final visibles = _tab == 0 ? aVenir : historique;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mes billets',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            all.isEmpty
                                ? 'Vos billets achetés apparaîtront ici'
                                : '${all.length} billet${all.length > 1 ? 's' : ''} au total',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTabs(aVenir.length, historique.length),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  if (visibles.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildTicketCard(visibles[index]),
                          ),
                          childCount: visibles.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: Menu(
          current: MenuItem.billets,
          onSelect: _onMenuSelect,
        ),
      ),
    );
  }

  // ───────────── Onglets ─────────────

  Widget _buildTabs(int nAVenir, int nHistorique) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('À venir', nAVenir, 0)),
          Expanded(child: _buildTabButton('Historique', nHistorique, 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int count, int index) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.buttonGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textMuted,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.white.withOpacity(0.25)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppColors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────── État vide ─────────────

  Widget _buildEmptyState() {
    final aVenirTab = _tab == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              aVenirTab
                  ? Icons.confirmation_number_outlined
                  : Icons.history_rounded,
              size: 42,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            aVenirTab ? 'Aucun voyage à venir' : 'Aucun voyage passé',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            aVenirTab
                ? 'Réservez votre prochain trajet pour le voir apparaître ici.'
                : 'Vos voyages effectués s\'afficheront ici une fois terminés.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          if (aVenirTab) ...[
            const SizedBox(height: 20),
            SizedBox(
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
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Center(
                        child: Text(
                          'Réserver un trajet',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────── Carte billet ─────────────

  Widget _buildTicketCard(Billet b) {
    final upcoming = b.estAVenir;
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => BilletDetail(billet: b))),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: const BoxDecoration(
                  gradient: AppColors.buttonGradient,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: b.compagnie.image == null
                            ? const Icon(
                                Icons.directions_bus_rounded,
                                color: AppColors.secondary,
                                size: 18,
                              )
                            : Image.asset(
                                b.compagnie.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.directions_bus_rounded,
                                  color: AppColors.secondary,
                                  size: 18,
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b.compagnie.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      _buildStatusChip(upcoming),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          b.depart.isEmpty ? '—' : b.depart,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          b.arrivee.isEmpty ? '—' : b.arrivee,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDateCourte(b.dateVoyage)} · ${formatHeure(b.heure)} · ${b.travelersCount} pers.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Tarif.format(b.montantTransport),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _download(b),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.download_outlined,
                            size: 18,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool upcoming) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: upcoming
            ? AppColors.primary.withOpacity(0.12)
            : AppColors.textMuted.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        upcoming ? 'À venir' : 'Terminé',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: upcoming ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}
