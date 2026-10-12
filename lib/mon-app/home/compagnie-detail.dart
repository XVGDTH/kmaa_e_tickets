import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/compteur-ticket/compteur_ticket.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';
import 'package:kmaa_e_tickets/mon-app/horaire/horaire_chip.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/recap-paiement.dart';
import 'package:kmaa_e_tickets/mon-app/progress/step-progress.dart';
import 'package:kmaa_e_tickets/mon-app/selecteur-ville/selecteur-vile.dart';
import 'package:kmaa_e_tickets/mon-app/trajet-national-externe/trajet_national.dart';
import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

class CompagnieDetail extends StatefulWidget {
  const CompagnieDetail({
    super.key,
    required this.compagnie,
    this.lastName = '',
    this.firstName = '',
  });

  final Compagnie compagnie;
  final String lastName;
  final String firstName;

  @override
  State<CompagnieDetail> createState() => _CompagnieDetailState();
}

class _CompagnieDetailState extends State<CompagnieDetail> {
  late final List<DateTime> _days;
  int _selectedDay = 0;

  TripType _tripType = TripType.national;

  String? _departVille;
  final _paysController = TextEditingController();
  final _arriveeIntlController = TextEditingController();

  String? _destination;
  String? _selectedHoraire;
  // Gare? _gare;
  DepartGare? _gare;

  TicketSelection _ticketSelection = const TicketSelection(
    count: 1,
    names: ['Acheteur'],
  );

  static const _dayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _sectionTitle = TextStyle(
    color: AppColors.textDark,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  String get _buyerName => '${widget.firstName} ${widget.lastName}'.trim();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));
  }

  @override
  void dispose() {
    // _departController.dispose();
    _paysController.dispose();
    _arriveeIntlController.dispose();
    super.dispose();
  }

  bool get _showTicketSelector {
    if (_tripType == TripType.national) return _gare != null;
    return _paysController.text.trim().isNotEmpty &&
        _arriveeIntlController.text.trim().isNotEmpty &&
        _selectedHoraire != null;
  }

  int get _currentStep {
    if (!_showTicketSelector) {
      return _departVille != null ? 0 : 1;
    }
    return 2;
  }

  // void _onDepartChanged(String value) {
  //   setState(() {
  //     _destination = null;
  //     _selectedHoraire = null;
  //     _gare = null;
  //   });
  // }
  void _onDepartChanged(String ville) {
    setState(() {
      _departVille = ville;
      _destination = null;
      _selectedHoraire = null;
      _gare = null;
    });
  }

  void _onContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecapPaiement(
          compagnie: widget.compagnie,
          tripType: _tripType,
          date: _days[_selectedDay],
          hour: _selectedHoraire!,
          depart: _departVille ?? ''.trim(),
          destination: _tripType == TripType.national
              ? _destination!
              : _arriveeIntlController.text.trim(),
          gare: _gare,
          pays: _tripType == TripType.international
              ? _paysController.text.trim()
              : null,
          ticketSelection: _ticketSelection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.compagnie;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(c)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StepProgress(currentStep: _currentStep),
                      const SizedBox(height: 24),
                      const Text('Type de trajet', style: _sectionTitle),
                      const SizedBox(height: 12),
                      TripTypeSelector(
                        value: _tripType,
                        onChanged: (v) => setState(() {
                          _tripType = v;
                          _destination = null;
                          _selectedHoraire = null;
                          _gare = null;
                        }),
                      ),
                      const SizedBox(height: 24),
                      const Text('Choisissez votre date', style: _sectionTitle),
                      const SizedBox(height: 12),
                      _buildDayStrip(),
                      const SizedBox(height: 24),
                      Text(
                        _tripType == TripType.national
                            ? 'Votre lieu de résidence (départ)'
                            : 'Ville de départ',
                        style: _sectionTitle,
                      ),
                      const SizedBox(height: 12),
                      VilleSelector(
                        villes: villesDepartDisponibles(widget.compagnie.id),
                        selected: _departVille,
                        onSelected: _onDepartChanged,
                      ),
                      if (_tripType == TripType.national) ...[
                        // if (_departController.text.trim().isNotEmpty) ...[
                        if (_departVille != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Choisissez votre destination et l\'heure',
                            style: _sectionTitle,
                          ),
                          const SizedBox(height: 12),
                          _buildRouteCards(),
                        ],
                        // if (_destination != null) ...[
                        //   const SizedBox(height: 20),
                        //   const Text(
                        //     'Choisissez votre gare de départ',
                        //     style: _sectionTitle,
                        //   ),
                        //   const SizedBox(height: 12),
                        //   _buildGareList(),
                        // ],
                      ] else ...[
                        const SizedBox(height: 12),
                        // VilleSelector(
                        //   villes: villesDepartDisponibles(widget.compagnie.id),
                        //   selected: _departVille,
                        //   onSelected: _onDepartChanged,
                        // ),
                        // const SizedBox(height: 12),
                        _buildField(
                          _arriveeIntlController,
                          'Ville de destination',
                          Icons.location_on_outlined,
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_paysController.text.trim().isNotEmpty &&
                            _arriveeIntlController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text('Heure de départ', style: _sectionTitle),
                          const SizedBox(height: 12),
                          HoraireChips(
                            horaires: horairesInternationalDefaut,
                            selected: _selectedHoraire,
                            onSelect: (h) =>
                                setState(() => _selectedHoraire = h),
                          ),
                        ],
                      ],

                      if (_showTicketSelector) ...[
                        const SizedBox(height: 24),
                        const Text('Vos tickets', style: _sectionTitle),
                        const SizedBox(height: 12),
                        TicketCountSelector(
                          buyerName: _buyerName,
                          onChanged: (s) =>
                              setState(() => _ticketSelection = s),
                        ),
                      ],

                      const SizedBox(height: 28),
                      _buildContinueButton(),
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

  Widget _buildHeader(Compagnie c) {
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
              _buildLogo(c),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (c.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            c.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(Compagnie c) {
    return Container(
      width: 64,
      height: 64,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: c.image == null
          ? const Icon(
              Icons.directions_bus_rounded,
              color: AppColors.secondary,
              size: 30,
            )
          : Image.asset(
              c.image!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.directions_bus_rounded,
                color: AppColors.secondary,
                size: 30,
              ),
            ),
    );
  }

  Widget _buildDayStrip() {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          for (var i = 0; i < _days.length; i++) Expanded(child: _buildDay(i)),
        ],
      ),
    );
  }

  Widget _buildDay(int index) {
    final selected = index == _selectedDay;
    final date = _days[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedDay = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.buttonGradient : null,
          color: selected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dayLetters[date.weekday - 1],
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: AppColors.textDark, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCards() {
    final routes = routesDepuis(widget.compagnie.id, _departVille ?? '');
    if (routes.isEmpty) {
      return const Text(
        'Aucune destination trouvée pour cette ville.',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
      );
    }
    final depart = _departVille ?? '';
    return Column(
      children: [
        for (final route in routes)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _destination == route.destination
                    ? AppColors.secondary
                    : AppColors.border,
                width: _destination == route.destination ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_bus_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$depart → ${route.destination}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final g in route.gares)
                  _buildGareBlock(route.destination, g),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGareBlock(String destination, DepartGare g) {
    final selected =
        _destination == destination && _gare?.quartier == g.quartier;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.secondary.withOpacity(0.06)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.secondary : AppColors.border,
        ),
      ),
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
                  g.quartier,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '${g.prixTicket} FCFA',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          if (g.telephone.isNotEmpty || g.dureeMax != '—') ...[
            const SizedBox(height: 2),
            Text(
              [
                if (g.dureeMax != '—') 'Durée max ${g.dureeMax}',
                if (g.telephone.isNotEmpty) '☎ ${g.telephone}',
              ].join('  •  '),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 8),
          HoraireChips(
            horaires: g.horaires,
            selected: selected ? _selectedHoraire : null,
            onSelect: (h) => setState(() {
              _destination = destination;
              _selectedHoraire = h;
              _gare = g;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final radius = BorderRadius.circular(8);
    final enabled = _showTicketSelector;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: enabled ? AppColors.buttonGradient : null,
          color: enabled ? null : AppColors.border,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? _onContinue : null,
            child: Center(
              child: Text(
                'Continuer',
                style: TextStyle(
                  color: enabled ? AppColors.white : AppColors.textMuted,
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
