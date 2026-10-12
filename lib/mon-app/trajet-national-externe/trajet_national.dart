import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

enum TripType { national, international }

class TripTypeSelector extends StatelessWidget {
  const TripTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TripType value;
  final ValueChanged<TripType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOption(
              TripType.national,
              'National',
              Icons.map_outlined,
            ),
          ),
          Expanded(
            child: _buildOption(
              TripType.international,
              'International',
              Icons.public,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(TripType type, String label, IconData icon) {
    final selected = type == value;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.buttonGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
