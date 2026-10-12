import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

/// Champ qui ouvre une liste à choix unique des villes de départ
/// disponibles, avec l'option sélectionnée mise en évidence.
class VilleSelector extends StatelessWidget {
  const VilleSelector({
    super.key,
    required this.villes,
    required this.selected,
    required this.onSelected,
    this.hint = 'Choisir une ville de départ',
  });

  final List<String> villes;
  final String? selected;
  final ValueChanged<String> onSelected;
  final String hint;

  Future<void> _open(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VilleSheet(villes: villes, selected: selected),
    );
    if (result != null) onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = villes.isEmpty;
    return GestureDetector(
      onTap: disabled ? null : () => _open(context),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.trip_origin, color: AppColors.textMuted, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                disabled
                    ? 'Aucune ville disponible pour cette compagnie'
                    : (selected ?? hint),
                style: TextStyle(
                  color: selected == null
                      ? AppColors.textMuted
                      : AppColors.textDark,
                  fontSize: 15,
                  fontWeight: selected == null
                      ? FontWeight.normal
                      : FontWeight.w700,
                ),
              ),
            ),
            if (!disabled)
              const Icon(
                Icons.expand_more,
                color: AppColors.textMuted,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _VilleSheet extends StatelessWidget {
  const _VilleSheet({required this.villes, required this.selected});
  final List<String> villes;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ville de départ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [for (final v in villes) _buildOption(context, v)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String ville) {
    final isSelected = ville == selected;
    return InkWell(
      onTap: () => Navigator.of(context).pop(ville),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.secondary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              ville,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.secondary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
