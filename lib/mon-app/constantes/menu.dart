// import 'package:flutter/material.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

// enum MenuItem { accueil, billets, notifications, profil }

// class Menu extends StatelessWidget {
//   const Menu({super.key, required this.current, required this.onSelect});

//   final MenuItem current;
//   final ValueChanged<MenuItem> onSelect;

//   static const _items = [
//     _NavEntry(
//       MenuItem.accueil,
//       Icons.home_outlined,
//       Icons.home_rounded,
//       'Accueil',
//     ),
//     _NavEntry(
//       MenuItem.billets,
//       Icons.confirmation_number_outlined,
//       Icons.confirmation_number_rounded,
//       'Mes billets',
//     ),
//     _NavEntry(
//       MenuItem.notifications,
//       Icons.notifications_none_rounded,
//       Icons.notifications_rounded,
//       'Notifications',
//     ),
//     _NavEntry(
//       MenuItem.profil,
//       Icons.person_outline_rounded,
//       Icons.person_rounded,
//       'Profil',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       top: false,
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//         height: 68,
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(28),
//           boxShadow: const [
//             BoxShadow(
//               color: Color(0x22000000),
//               blurRadius: 16,
//               offset: Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [for (final e in _items) Expanded(child: _buildItem(e))],
//         ),
//       ),
//     );
//   }

//   Widget _buildItem(_NavEntry e) {
//     final selected = e.item == current;
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: () => onSelect(e.item),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
//         decoration: BoxDecoration(
//           gradient: selected ? AppColors.buttonGradient : null,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               selected ? e.activeIcon : e.icon,
//               color: selected ? AppColors.white : AppColors.textMuted,
//               size: 23,
//             ),
//             const SizedBox(height: 3),
//             Text(
//               e.label,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//                 color: selected ? AppColors.white : AppColors.textMuted,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _NavEntry {
//   const _NavEntry(this.item, this.icon, this.activeIcon, this.label);
//   final MenuItem item;
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
// }

import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';

enum MenuItem { accueil, billets, notifications, profil }

class Menu extends StatelessWidget {
  const Menu({super.key, required this.current, required this.onSelect});

  final MenuItem current;
  final ValueChanged<MenuItem> onSelect;

  static const _items = [
    _NavEntry(
      MenuItem.accueil,
      Icons.home_outlined,
      Icons.home_rounded,
      'Accueil',
    ),
    _NavEntry(
      MenuItem.billets,
      Icons.confirmation_number_outlined,
      Icons.confirmation_number_rounded,
      'Mes billets',
    ),
    _NavEntry(
      MenuItem.notifications,
      Icons.notifications_none_rounded,
      Icons.notifications_rounded,
      'Notifications',
    ),
    _NavEntry(
      MenuItem.profil,
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [for (final e in _items) Expanded(child: _buildItem(e))],
        ),
      ),
    );
  }

  Widget _buildItem(_NavEntry e) {
    final selected = e.item == current;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onSelect(e.item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.buttonGradient : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconWithBadge(e, selected),
            const SizedBox(height: 3),
            Text(
              e.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(_NavEntry e, bool selected) {
    final icon = Icon(
      selected ? e.activeIcon : e.icon,
      color: selected ? AppColors.white : AppColors.textMuted,
      size: 23,
    );

    if (e.item == MenuItem.notifications) {
      return ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: NotificationStore.instance.items,
        builder: (context, items, _) =>
            _withBadge(icon, items.where((n) => !n.read).length),
      );
    }
    if (e.item == MenuItem.billets) {
      return ValueListenableBuilder<List<Billet>>(
        valueListenable: TicketStore.instance.billets,
        builder: (context, billets, _) =>
            _withBadge(icon, billets.where((b) => b.estAVenir).length),
      );
    }
    return icon;
  }

  Widget _withBadge(Widget icon, int count) {
    if (count <= 0) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -4,
          right: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            constraints: const BoxConstraints(minWidth: 16),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.white, width: 1.5),
            ),
            child: Text(
              count > 9 ? '9+' : '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavEntry {
  const _NavEntry(this.item, this.icon, this.activeIcon, this.label);
  final MenuItem item;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
