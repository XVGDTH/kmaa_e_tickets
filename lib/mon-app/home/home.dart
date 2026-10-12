// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/menu.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
// import 'package:kmaa_e_tickets/mon-app/gares_favorites/favorites.dart';
// import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';
// import 'package:kmaa_e_tickets/mon-app/home/compagnie_card.dart';
// import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/bandeau_rappel.dart';

// class Home extends StatefulWidget {
//   const Home({super.key, this.lastName = '', this.firstName = ''});

//   final String lastName;
//   final String firstName;

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final _searchController = TextEditingController();
//   final Set<String> _favorites = {};
//   late final List<DateTime> _days;

//   String _query = '';
//   int _selectedDay = 0;

//   @override
//   void initState() {
//     super.initState();
//     final now = DateTime.now();
//     _days = List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ───────────── Données dérivées ─────────────

//   String get _initials {
//     final f = widget.firstName.trim();
//     final l = widget.lastName.trim();
//     final a = f.isNotEmpty ? f[0] : '';
//     final b = l.isNotEmpty ? l[0] : '';
//     final result = '$a$b'.toUpperCase();
//     return result.isEmpty ? '?' : result;
//   }

//   String get _fullName {
//     final name = '${widget.firstName} ${widget.lastName}'.trim();
//     return name.isEmpty ? 'Voyageur' : name;
//   }

//   String get _greeting => DateTime.now().hour < 18 ? 'Bonjour !' : 'Bonsoir !';

//   List<Compagnie> get _filtered =>
//       kCompagnies.where((c) => c.name.toLowerCase().contains(_query)).toList();

//   // ───────────── Actions ─────────────

//   // void _onCompagnieTap(Compagnie c) {
//   //   Navigator.of(context).pushNamed('/compagnie/${c.id}', arguments: c);
//   // }
//   void _onCompagnieTap(Compagnie c) {
//     Navigator.of(context).pushNamed(
//       '/compagnie/${c.id}',
//       arguments: {
//         'compagnie': c,
//         'nom': widget.lastName,
//         'prenom': widget.firstName,
//       },
//     );
//   }

//   void _toggleFavorite(String name) {
//     setState(() {
//       if (!_favorites.remove(name)) _favorites.add(name);
//     });
//   }

//   void _showAll() {
//     _searchController.clear();
//     setState(() => _query = '');
//   }

//   // navigation des menus

//   void _onMenuSelect(MenuItem item) {
//     AppRoutes.navigateFromMenu(
//       context,
//       item,
//       nom: widget.lastName,
//       prenom: widget.firstName,
//     );
//   }

//   // ───────────── Build ─────────────

//   @override
//   Widget build(BuildContext context) {
//     final list = _filtered;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: SafeArea(
//           child: CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
//                   child: Column(
//                     // children: [
//                     //   _buildHeader(),
//                     //   // rappel appel et voix
//                     //   _buildHeader(),
//                     //   const ReminderBanner(),
//                     //   const SizedBox(height: 20),

//                     //   const SizedBox(height: 20),
//                     //   _buildSearchBar(),
//                     children: [
//                       _buildHeader(),
//                       const ReminderBanner(),
//                       const SizedBox(height: 20),
//                       _buildSearchBar(),
//                       const SizedBox(height: 24),
//                       _buildSectionTitle(),
//                       const SizedBox(height: 12),
//                     ],
//                   ),
//                 ),
//               ),
//               if (list.isEmpty)
//                 const SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.all(40),
//                     child: Center(
//                       child: Text(
//                         'Aucune compagnie trouvée',
//                         style: TextStyle(
//                           color: AppColors.textMuted,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               else
//                 SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
//                   sliver: SliverList(
//                     delegate: SliverChildBuilderDelegate((context, index) {
//                       final c = list[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: CompagnieCard(
//                           compagnie: c,
//                           days: _days,
//                           selectedDay: _selectedDay,
//                           onDaySelected: (i) =>
//                               setState(() => _selectedDay = i),
//                           isFavorite: _favorites.contains(c.name),
//                           onFavorite: () => _toggleFavorite(c.name),
//                           onTap: () => _onCompagnieTap(c),
//                         ),
//                       );
//                     }, childCount: list.length),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: Menu(
//           current: MenuItem.accueil,
//           onSelect: _onMenuSelect,
//         ),
//       ),
//     );
//   }

//   // ───────────── En-tête ─────────────

//   // Widget _buildHeader() {
//   //   return Row(
//   //     children: [
//   //       _buildAvatar(),
//   //       const SizedBox(width: 12),
//   //       Expanded(
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             Text(
//   //               _fullName,
//   //               maxLines: 1,
//   //               overflow: TextOverflow.ellipsis,
//   //               style: const TextStyle(
//   //                 color: AppColors.textDark,
//   //                 fontSize: 17,
//   //                 fontWeight: FontWeight.w800,
//   //               ),
//   //             ),
//   //             const SizedBox(height: 2),
//   //             Text(
//   //               _greeting,
//   //               style: const TextStyle(
//   //                 color: AppColors.textMuted,
//   //                 fontSize: 13,
//   //                 fontWeight: FontWeight.w600,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //       const SizedBox(width: 12),
//   //       _buildBell(),
//   //     ],
//   //   );
//   // }
//   Widget _buildHeader() {
//     return Row(
//       children: [
//         _buildAvatar(),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 _fullName,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: AppColors.textDark,
//                   fontSize: 17,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 _greeting,
//                 style: const TextStyle(
//                   color: AppColors.textMuted,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAvatar() {
//     return Container(
//       width: 48,
//       height: 48,
//       alignment: Alignment.center,
//       decoration: const BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.primary, AppColors.secondary],
//         ),
//       ),
//       child: Text(
//         _initials,
//         style: const TextStyle(
//           color: AppColors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }

//   Widget _buildBell() {
//     return Material(
//       color: AppColors.white,
//       elevation: 2,
//       shadowColor: Colors.black38,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: () {
//           // TODO: ouvrir les notifications.
//           debugPrint('Notifications');
//         },
//         child: const SizedBox(
//           width: 46,
//           height: 46,
//           child: Icon(
//             Icons.notifications_none_rounded,
//             color: AppColors.secondary,
//             size: 24,
//           ),
//         ),
//       ),
//     );
//   }

//   // ───────────── Recherche ─────────────

//   Widget _buildSearchBar() {
//     return Container(
//       height: 54,
//       padding: const EdgeInsets.symmetric(horizontal: 9),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x14000000),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: const BoxDecoration(
//               color: AppColors.secondary,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.location_on_outlined,
//               color: AppColors.white,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
//               style: const TextStyle(color: AppColors.textDark, fontSize: 16),
//               decoration: const InputDecoration(
//                 hintText: 'Rechercher une compagnie',
//                 hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15),
//                 border: InputBorder.none,
//                 isDense: true,
//               ),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(right: 8),
//             child: Icon(Icons.search, color: AppColors.textDark, size: 24),
//           ),
//         ],
//       ),
//     );
//   }

//   // ───────────── Titre de section ─────────────

//   Widget _buildSectionTitle() {
//     return Row(
//       children: [
//         const Expanded(
//           child: Text(
//             'Compagnies de transport',
//             style: TextStyle(
//               color: AppColors.textDark,
//               fontSize: 20,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//         TextButton(
//           onPressed: _showAll,
//           style: TextButton.styleFrom(
//             foregroundColor: AppColors.textDark,
//             padding: EdgeInsets.zero,
//             minimumSize: const Size(48, 32),
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//           child: const Text(
//             'Voir tout',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/menu.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/gares_favorites/favorites.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie_card.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/avis_banner.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/bandeau_rappel.dart';

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));
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

  List<Compagnie> _filtered(Set<String> favIds) {
    var list = kCompagnies.where((c) => c.name.toLowerCase().contains(_query));
    if (_favorisUniquement) list = list.where((c) => favIds.contains(c.id));
    return list.toList();
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
                          const ReminderBanner(),
                          const AvisBanner(),
                          const SizedBox(height: 20),
                          _buildSearchBar(),
                          const SizedBox(height: 24),
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
