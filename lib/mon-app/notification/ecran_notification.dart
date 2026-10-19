import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/menu.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/formulaire_notation.dart';
import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';

// class NotificationsScreen extends StatelessWidget {
//   const NotificationsScreen({super.key});
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationStore.instance
        .rafraichir(); // à jour à chaque ouverture de l'écran
  }

  void _onMenuSelect(BuildContext context, MenuItem item) =>
      AppRoutes.navigateFromMenu(context, item);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ValueListenableBuilder<List<NotificationItem>>(
            valueListenable: NotificationStore.instance.items,
            builder: (context, all, _) {
              final groupes = _grouperParPeriode(all);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(all)),
                  if (all.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          for (final groupe in groupes.entries) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                                top: 8,
                              ),
                              child: Text(
                                groupe.key,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            for (final n in groupe.value)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildItem(context, n),
                              ),
                          ],
                        ]),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: Menu(
          current: MenuItem.notifications,
          onSelect: (i) => _onMenuSelect(context, i),
        ),
      ),
    );
  }

  // ───────────── En-tête ─────────────

  Widget _buildHeader(List<NotificationItem> all) {
    final unread = all.where((n) => !n.read).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (unread > 0)
            TextButton(
              onPressed: () => NotificationStore.instance.markAllRead(),
              child: const Text(
                'Tout marquer lu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────── Regroupement par période ─────────────

  Map<String, List<NotificationItem>> _grouperParPeriode(
    List<NotificationItem> all,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final map = <String, List<NotificationItem>>{
      "Aujourd'hui": [],
      'Cette semaine': [],
      'Plus ancien': [],
    };
    for (final n in all) {
      final d = DateTime(n.date.year, n.date.month, n.date.day);
      if (d == today) {
        map["Aujourd'hui"]!.add(n);
      } else if (today.difference(d).inDays <= 7) {
        map['Cette semaine']!.add(n);
      } else {
        map['Plus ancien']!.add(n);
      }
    }
    map.removeWhere((key, value) => value.isEmpty);
    return map;
  }

  // ───────────── Élément de notification ─────────────

  Widget _buildItem(BuildContext context, NotificationItem n) {
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.white),
      ),
      onDismissed: (_) => NotificationStore.instance.delete(n.id),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // onTap: () => NotificationStore.instance.markRead(n.id),
        onTap: () {
          NotificationStore.instance.markRead(n.id);
          if (n.type == NotifType.avis && n.billetReference != null) {
            final billet = TicketStore.instance.billets.value
                .where((b) => b.reference == n.billetReference)
                .firstOrNull;
            if (billet != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NotationGareScreen(billet: billet),
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: n.read
                  ? AppColors.border
                  : AppColors.secondary.withOpacity(0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(n.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (!n.read)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(n.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(NotifType type) {
    final (icon, color) = switch (type) {
      NotifType.achat => (Icons.confirmation_number_rounded, AppColors.primary),
      NotifType.rappel => (Icons.schedule_rounded, AppColors.secondary),
      NotifType.promo => (Icons.local_offer_rounded, AppColors.primary),
      NotifType.avis => (Icons.star_rounded, AppColors.secondary),
      NotifType.info => (Icons.info_rounded, AppColors.textMuted),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ───────────── État vide ─────────────

  Widget _buildEmptyState() {
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
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 42,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous serez informé ici de vos achats et rappels de départ.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
