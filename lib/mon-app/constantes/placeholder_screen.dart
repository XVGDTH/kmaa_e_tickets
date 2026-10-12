import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/menu.dart';

/// Écran temporaire pour un onglet du menu pas encore construit.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.current,
    required this.onMenuSelect,
  });

  final String title;
  final IconData icon;
  final MenuItem current;
  final ValueChanged<MenuItem> onMenuSelect;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bientôt disponible',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Menu(current: current, onSelect: onMenuSelect),
      ),
    );
  }
}
