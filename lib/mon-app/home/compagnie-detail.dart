import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
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
  // final _paysController = TextEditingController();
  // final _arriveeIntlController = TextEditingController();

  String? _destination;
  String? _selectedHoraire;
  DepartGare? _gare;
  String? _pays; // pays de la destination choisie (trajets internationaux)

  // Données venant du serveur
  List<String> _villesDepart = const [];
  bool _villesChargees = false;
  String? _erreurVilles;
  List<RouteOption> _routes = const [];
  bool _chargementRoutes = false;
  String? _erreurRoutes;
  int _requete = 0; // ignore la réponse d'une recherche déjà remplacée

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
    _chargerVilles();
  }

  @override
  void dispose() {
    // _paysController.dispose();
    // _arriveeIntlController.dispose();
    super.dispose();
  }

  void _onTypeChange(TripType v) {
    if (v == _tripType) return;
    setState(() {
      _tripType = v;
      _departVille = null;
      _destination = null;
      _pays = null;
      _selectedHoraire = null;
      _gare = null;
      _routes = const [];
      _villesDepart = const [];
      _erreurRoutes = null;
      _requete++;
    });
    _chargerVilles();
  }

  // ───────────── Données du serveur ─────────────

  Future<void> _chargerVilles() async {
    final type = _tripType;
    setState(() {
      _erreurVilles = null;
      _villesChargees = false;
    });
    try {
      final villes = await ApiService.instance.fetchVillesDepart(
        widget.compagnie.id,
        type: type.name,
      );
      if (!mounted || type != _tripType) return;
      setState(() {
        _villesDepart = villes;
        _villesChargees = true;
      });
    } on ApiException catch (e) {
      if (!mounted || type != _tripType) return;
      setState(() {
        _villesChargees = true;
        _erreurVilles = e.message;
      });
    }
  }

  Future<void> _chargerRoutes() async {
    final ville = _departVille;
    if (ville == null) return;

    final numero = ++_requete;
    setState(() {
      _chargementRoutes = true;
      _erreurRoutes = null;
    });

    try {
      final data = await ApiService.instance.fetchRoutes(
        compagnieSlug: widget.compagnie.id,
        depart: ville,
        date: _days[_selectedDay],
        type: _tripType.name,
      );
      if (!mounted || numero != _requete) return;

      // On ne garde que les gares qui ont au moins un départ ce jour-là.
      final routes = data
          .map(RouteOption.fromJson)
          .map(
            (r) => RouteOption(
              destination: r.destination,
              pays: r.pays,
              etranger: r.etranger,
              gares: r.gares.where((g) => g.horaires.isNotEmpty).toList(),
            ),
          )
          .where((r) => r.gares.isNotEmpty)
          .toList();

      setState(() {
        _routes = routes;
        _chargementRoutes = false;
      });
    } on ApiException catch (e) {
      if (!mounted || numero != _requete) return;
      setState(() {
        _routes = const [];
        _chargementRoutes = false;
        _erreurRoutes = e.message;
      });
    }
  }

  /// Cache les départs déjà passés (aujourd'hui) et ceux qui n'ont plus de place.
  List<String> _horairesAffichables(DepartGare g) {
    final maintenant = DateTime.now();
    final jour = _days[_selectedDay];

    return g.horaires.where((h) {
      if ((g.disponibilites[h] ?? 1) <= 0) return false;
      final m = RegExp(r'^(\d{1,2})\D+(\d{2})').firstMatch(h);
      if (m == null) return true;
      final depart = DateTime(
        jour.year,
        jour.month,
        jour.day,
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
      );
      return depart.isAfter(maintenant);
    }).toList();
  }

  // bool get _showTicketSelector {
  //   if (_tripType == TripType.national) return _gare != null;
  //   return _paysController.text.trim().isNotEmpty &&
  //       _arriveeIntlController.text.trim().isNotEmpty &&
  //       _selectedHoraire != null;
  // }
  bool get _showTicketSelector => _gare != null;

  int get _currentStep {
    if (!_showTicketSelector) {
      return _departVille != null ? 0 : 1;
    }
    return 2;
  }

  void _onDepartChanged(String ville) {
    setState(() {
      _departVille = ville;
      _destination = null;
      _selectedHoraire = null;
      _gare = null;
      _routes = const [];
    });
    _chargerRoutes();
  }

  // void _onContinue() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (_) => RecapPaiement(
  //         compagnie: widget.compagnie,
  //         tripType: _tripType,
  //         date: _days[_selectedDay],
  //         hour: _selectedHoraire!,
  //         depart: _departVille ?? ''.trim(),
  //         destination: _tripType == TripType.national
  //             ? _destination!
  //             : _arriveeIntlController.text.trim(),
  //         gare: _gare,
  //         pays: _tripType == TripType.international
  //             ? _paysController.text.trim()
  //             : null,
  //         ticketSelection: _ticketSelection,
  //       ),
  //     ),
  //   );
  // }
  void _onContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecapPaiement(
          compagnie: widget.compagnie,
          tripType: _tripType,
          date: _days[_selectedDay],
          hour: _selectedHoraire!,
          depart: _departVille ?? '',
          destination: _destination!,
          gare: _gare,
          pays: _tripType == TripType.international ? _pays : null,
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
                        // onChanged: (v) => setState(() {
                        //   _tripType = v;
                        //   _destination = null;
                        //   _selectedHoraire = null;
                        //   _gare = null;
                        // }),
                        onChanged: _onTypeChange,
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
                        villes: _villesDepart,
                        selected: _departVille,
                        onSelected: _onDepartChanged,
                      ),
                      if (_erreurVilles != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _erreurVilles!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                        TextButton(
                          onPressed: _chargerVilles,
                          child: const Text('Réessayer'),
                        ),
                      ] else if (_villesChargees && _villesDepart.isEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Aucun départ disponible pour cette compagnie pour le moment.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      // if (_tripType == TripType.national) ...[
                      //   if (_departVille != null) ...[
                      //     const SizedBox(height: 20),
                      //     const Text(
                      //       'Choisissez votre destination et l\'heure',
                      //       style: _sectionTitle,
                      //     ),
                      //     const SizedBox(height: 12),
                      //     _buildRouteCards(),
                      //   ],
                      // ] else ...[
                      //   const SizedBox(height: 12),
                      //   _buildField(
                      //     _arriveeIntlController,
                      //     'Ville de destination',
                      //     Icons.location_on_outlined,
                      //     onChanged: (_) => setState(() {}),
                      //   ),
                      //   if (_paysController.text.trim().isNotEmpty &&
                      //       _arriveeIntlController.text.trim().isNotEmpty) ...[
                      //     const SizedBox(height: 20),
                      //     const Text('Heure de départ', style: _sectionTitle),
                      //     const SizedBox(height: 12),
                      //     HoraireChips(
                      //       horaires: horairesInternationalDefaut,
                      //       selected: _selectedHoraire,
                      //       onSelect: (h) =>
                      //           setState(() => _selectedHoraire = h),
                      //     ),
                      //   ],
                      // ],
                      if (_departVille != null) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Choisissez votre destination et l\'heure',
                          style: _sectionTitle,
                        ),
                        const SizedBox(height: 12),
                        _buildRouteCards(),
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
      onTap: () {
        setState(() {
          _selectedDay = index;
          _destination = null;
          _selectedHoraire = null;
          _gare = null;
        });
        _chargerRoutes();
      },
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

  Widget _buildRouteCards() {
    if (_chargementRoutes) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_erreurRoutes != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _erreurRoutes!,
            style: const TextStyle(fontSize: 13, color: AppColors.error),
          ),
          TextButton(onPressed: _chargerRoutes, child: const Text('Réessayer')),
        ],
      );
    }
    final routes = _routes;
    if (routes.isEmpty) {
      return const Text(
        'Aucun départ ce jour-là pour cette ville.',
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
                        // '$depart → ${route.destination}',
                        '$depart → ${route.destination}${route.etranger ? " (${route.pays})" : ""}',
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
            horaires: _horairesAffichables(g),
            selected: selected ? _selectedHoraire : null,
            onSelect: (h) => setState(() {
              _destination = destination;
              _selectedHoraire = h;
              _gare = g;
              _pays = _routes
                  .where((r) => r.destination == destination)
                  .firstOrNull
                  ?.pays;
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
