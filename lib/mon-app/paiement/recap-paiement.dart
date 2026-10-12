import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/compteur-ticket/compteur_ticket.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';
import 'package:kmaa_e_tickets/mon-app/tarifs/tarifs.dart';
import 'package:kmaa_e_tickets/mon-app/trajet-national-externe/trajet_national.dart';
import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/choix_operateur.dart';

class RecapPaiement extends StatelessWidget {
  const RecapPaiement({
    super.key,
    required this.compagnie,
    required this.tripType,
    required this.date,
    required this.hour,
    required this.depart,
    required this.destination,
    this.gare,
    this.pays,
    required this.ticketSelection,
  });

  final Compagnie compagnie;
  final TripType tripType;
  final DateTime date;
  final String hour;
  final String depart;
  final String destination;
  final DepartGare? gare;
  final String? pays;
  final TicketSelection ticketSelection;

  int get _prixUnitaire =>
      gare?.prixTicket ?? prixInternational(compagnie.id, destination);
  int get _montantTransport => _prixUnitaire * ticketSelection.count;
  int get _total => _montantTransport + Tarif.taxeFixe;

  void _onPay(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChoixOperateur(
          compagnie: compagnie,
          depart: depart,
          arrivee: destination,
          date: date,
          hour: hour,
          travelersCount: ticketSelection.count,
          montantTransport: _montantTransport,
          taxe: Tarif.taxeFixe,
          voyageurNames: ticketSelection.names,
          gare: gare,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final dateLabel =
        '${jours[date.weekday - 1]} ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTripCard(dateLabel),
                      const SizedBox(height: 20),
                      const Text(
                        'Détail du paiement',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInvoice(),
                      const SizedBox(height: 24),
                      _buildPayButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compagnie.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Récapitulatif du billet',
                      style: TextStyle(color: AppColors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 56,
      height: 56,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: compagnie.image == null
          ? const Icon(
              Icons.directions_bus_rounded,
              color: AppColors.secondary,
              size: 26,
            )
          : Image.asset(
              compagnie.image!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.directions_bus_rounded,
                color: AppColors.secondary,
                size: 26,
              ),
            ),
    );
  }

  Widget _buildTripCard(String dateLabel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildPointLabel(depart, isDestination: false),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
              _buildPointLabel(destination, isDestination: true),
            ],
          ),
          if (tripType == TripType.international &&
              (pays?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Destination : $pays',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (gare != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gare : ${gare!.quartier} · Durée max ${gare!.dureeMax}'
                '${gare!.telephone.isNotEmpty ? ' · ☎ ${gare!.telephone}' : ''}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const Divider(height: 28, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip(Icons.calendar_today_outlined, dateLabel),
              _buildInfoChip(Icons.schedule, hour),
              _buildInfoChip(
                Icons.confirmation_number_outlined,
                '${ticketSelection.count} ticket(s)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointLabel(String label, {required bool isDestination}) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDestination ? Icons.location_on : Icons.trip_origin,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label.isEmpty ? '—' : label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInvoiceRow(
            'Ticket × ${ticketSelection.count} (${Tarif.format(_prixUnitaire)} l\'unité)',
            _montantTransport,
          ),
          _buildInvoiceRow('Taxe (montant unique)', Tarif.taxeFixe),
          const Divider(height: 24, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total à payer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                Tarif.format(_total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, int amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            ),
          ),
          Text(
            Tarif.format(amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    final radius = BorderRadius.circular(8);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: AppColors.buttonGradient,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: () => _onPay(context),
            child: Center(
              child: Text(
                'Payer ${Tarif.format(_total)}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
