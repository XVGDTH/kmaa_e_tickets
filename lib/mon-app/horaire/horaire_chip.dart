import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

/// Icône du moment de la journée — aide à repérer l'heure même sans
/// bien déchiffrer les chiffres (matin/après-midi/soir).
IconData periodIcon(String horaire) {
  final h = int.tryParse(horaire.split('h').first) ?? 0;
  if (h < 12) return Icons.wb_twilight_rounded;
  if (h < 18) return Icons.wb_sunny_rounded;
  return Icons.nightlight_round;
}

Color periodColor(String horaire) {
  final h = int.tryParse(horaire.split('h').first) ?? 0;
  if (h < 12) return const Color(0xFFE79724);
  if (h < 18) return const Color(0xFFD9250A);
  return const Color(0xFF3B3F8C);
}

/// Rangée de créneaux horaires sélectionnables, avec pictogramme.
class HoraireChips extends StatelessWidget {
  const HoraireChips({
    super.key,
    required this.horaires,
    required this.selected,
    required this.onSelect,
  });

  final List<String> horaires;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final h in horaires) _buildChip(h)],
    );
  }

  Widget _buildChip(String h) {
    final isSelected = h == selected;
    return GestureDetector(
      onTap: () => onSelect(h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.buttonGradient : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              periodIcon(h),
              size: 16,
              color: isSelected ? AppColors.white : periodColor(h),
            ),
            const SizedBox(width: 6),
            Text(
              h,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
