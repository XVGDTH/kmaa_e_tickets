import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/bienvenue/bandeau_bienvenue.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/menu.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/gares_favorites/favorites.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie_card.dart';
import 'package:kmaa_e_tickets/mon-app/marketing/offres_whatsapp.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/avis_banner.dart';
import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/bandeau_rappel.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/service-rappel.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.lastName = '', this.firstName = ''});

  final String lastName;
  final String firstName;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _searchController = TextEditingController();
  late final List<DateTime> _days;

  String _query = '';
  int _selectedDay = 0;
  bool _favorisUniquement = false;
  Set<String>? _compagniesActives; // null = pas encore connu (ou hors ligne)
  List<({String compagnie, int billets})> _preferees = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));

    TicketStore.instance.rafraichir().then(
      (_) => AlertService.instance
          .replanifierTous(), // rappels à jour après chaque synchronisation
    );
    _chargerCompagnies();
    _chargerPreferees();
    NotificationStore.instance.rafraichir();

    // Une seule fois, aux clients qui n'ont jamais répondu : accepter ou non les offres.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) PromptOffres.afficherSiNecessaire(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _initials {
    final f = widget.firstName.trim();
    final l = widget.lastName.trim();
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    final result = '$a$b'.toUpperCase();
    return result.isEmpty ? '?' : result;
  }

  String get _fullName {
    final name = '${widget.firstName} ${widget.lastName}'.trim();
    return name.isEmpty ? 'Voyageur' : name;
  }

  String get _greeting => DateTime.now().hour < 18 ? 'Bonjour !' : 'Bonsoir !';

  /// Les compagnies préférées du client passent en premier.
  List<Compagnie> _filtered(Set<String> favIds) {
    var list = kCompagnies.where((c) => c.name.toLowerCase().contains(_query));
    final actives = _compagniesActives;
    if (actives != null) list = list.where((c) => actives.contains(c.id));
    if (_favorisUniquement) list = list.where((c) => favIds.contains(c.id));

    final resultat = list.toList();

    if (_preferees.isNotEmpty && _query.isEmpty) {
      final rang = {
        for (var i = 0; i < _preferees.length; i++) _preferees[i].compagnie: i,
      };
      final ordreInitial = {
        for (var i = 0; i < resultat.length; i++) resultat[i].id: i,
      };

      resultat.sort((a, b) {
        final c = (rang[a.id] ?? 999).compareTo(rang[b.id] ?? 999);
        return c != 0 ? c : ordreInitial[a.id]!.compareTo(ordreInitial[b.id]!);
      });
    }

    return resultat;
  }

  void _onCompagnieTap(Compagnie c) {
    Navigator.of(context).pushNamed(
      '/compagnie/${c.id}',
      arguments: {
        'compagnie': c,
        'nom': widget.lastName,
        'prenom': widget.firstName,
      },
    );
  }

  void _showAll() {
    _searchController.clear();
    setState(() {
      _query = '';
      _favorisUniquement = false;
    });
  }

  void _onMenuSelect(MenuItem item) {
    AppRoutes.navigateFromMenu(
      context,
      item,
      nom: widget.lastName,
      prenom: widget.firstName,
    );
  }

  Future<void> _chargerCompagnies() async {
    try {
      final liste = await ApiService.instance.fetchCompagnies();
      if (!mounted) return;
      setState(
        () => _compagniesActives = liste.map((c) => '${c['slug']}').toSet(),
      );
    } on ApiException {
      // hors ligne : on garde la liste locale
    }
  }

  Future<void> _chargerPreferees() async {
    try {
      final liste = await ApiService.instance.mesCompagniesPreferees();
      if (!mounted) return;
      setState(() => _preferees = liste);
    } catch (_) {
      // hors ligne : l'ordre habituel reste
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: FavorisStore.instance.ids,
            builder: (context, favIds, _) {
              final list = _filtered(favIds);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const BandeauBienvenue(),
                          const ReminderBanner(),
                          const AvisBanner(),
                          const SizedBox(height: 20),
                          _buildSearchBar(),
                          const SizedBox(height: 20),
                          _buildDernierVoyage(),
                          _buildVosCompagnies(),
                          const SizedBox(height: 4),
                          _buildSectionTitle(favIds.isNotEmpty),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  if (list.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final c = list[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CompagnieCard(
                              compagnie: c,
                              days: _days,
                              selectedDay: _selectedDay,
                              onDaySelected: (i) =>
                                  setState(() => _selectedDay = i),
                              isFavorite: favIds.contains(c.id),
                              onFavorite: () =>
                                  FavorisStore.instance.toggle(c.id),
                              onTap: () => _onCompagnieTap(c),
                            ),
                          );
                        }, childCount: list.length),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: Menu(
          current: MenuItem.accueil,
          onSelect: _onMenuSelect,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _greeting,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Text(
        _initials,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              style: const TextStyle(color: AppColors.textDark, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Rechercher une compagnie',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const Icon(Icons.search, color: AppColors.textDark, size: 24),
        ],
      ),
    );
  }

  /// « Refaire mon dernier voyage » : repart du billet le plus récent.
  Widget _buildDernierVoyage() {
    return ValueListenableBuilder<List<Billet>>(
      valueListenable: TicketStore.instance.billets,
      builder: (context, billets, _) {
        if (_query.isNotEmpty || _favorisUniquement) {
          return const SizedBox.shrink();
        }

        final valides = billets
            .where(
              (b) =>
                  b.statut != 'annule' &&
                  b.statut != 'rembourse' &&
                  b.statut != 'en_attente_paiement',
            )
            .toList();
        if (valides.isEmpty) return const SizedBox.shrink();

        final b =
            valides.first; // le magasin trie par date de paiement décroissante

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pushNamed(
              '/compagnie/${b.compagnie.id}',
              arguments: {
                'compagnie': b.compagnie,
                'nom': widget.lastName,
                'prenom': widget.firstName,
                'depart': b.depart,
                'destination': b.arrivee,
                'voyageurs': b.travelersCount,
              },
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.replay_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Refaire mon dernier voyage',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${b.depart} → ${b.arrivee} · ${b.compagnie.name} · ${b.travelersCount} voyageur(s)',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// « Vos compagnies » : les trois compagnies que le client utilise le plus.
  Widget _buildVosCompagnies() {
    if (_query.isNotEmpty || _favorisUniquement || _preferees.isEmpty) {
      return const SizedBox.shrink();
    }

    final cartes = <(Compagnie, int)>[];
    for (final p in _preferees.take(3)) {
      final c = kCompagnies.where((x) => x.id == p.compagnie).firstOrNull;
      if (c != null) cartes.add((c, p.billets));
    }
    if (cartes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos compagnies',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cartes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final (c, billets) = cartes[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _onCompagnieTap(c),
                  child: Container(
                    width: 190,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: i == 0 ? AppColors.secondary : AppColors.border,
                        width: i == 0 ? 1.6 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                          ),
                          child: c.image == null
                              ? const Icon(
                                  Icons.directions_bus_rounded,
                                  color: AppColors.secondary,
                                )
                              : Image.asset(
                                  c.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.directions_bus_rounded,
                                    color: AppColors.secondary,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                i == 0
                                    ? 'Votre préférée · $billets billet(s)'
                                    : '$billets billet(s)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(bool hasFavoris) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _favorisUniquement ? 'Mes favoris' : 'Compagnies de transport',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (hasFavoris || _favorisUniquement) _buildFavorisToggle(),
        if (!_favorisUniquement)
          TextButton(
            onPressed: _showAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textDark,
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Voir tout',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }

  Widget _buildFavorisToggle() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _favorisUniquement = !_favorisUniquement),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _favorisUniquement ? AppColors.secondary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _favorisUniquement ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: _favorisUniquement ? AppColors.white : AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Text(
          _favorisUniquement
              ? 'Aucun favori pour le moment'
              : 'Aucune compagnie trouvée',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
