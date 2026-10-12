import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

/// Repères visuels de progression, utiles même sans bien lire : chaque
/// étape a son propre pictogramme reconnaissable.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.currentStep});

  /// 0 = lieu de départ, 1 = trajet/horaire, 2 = tickets
  final int currentStep;

  static const _icons = [
    Icons.location_on_rounded,
    Icons.directions_bus_filled_rounded,
    Icons.confirmation_number_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _icons.length; i++) ...[
          _buildDot(i),
          if (i < _icons.length - 1) Expanded(child: _buildLine(i)),
        ],
      ],
    );
  }

  Widget _buildDot(int i) {
    final reached = i <= currentStep;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: reached ? AppColors.buttonGradient : null,
        color: reached ? null : AppColors.white,
        border: Border.all(
          color: reached ? Colors.transparent : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Icon(
        _icons[i],
        size: 16,
        color: reached ? AppColors.white : AppColors.textMuted,
      ),
    );
  }

  Widget _buildLine(int i) {
    final reached = i < currentStep;
    return Container(
      height: 2,
      color: reached ? AppColors.primary : AppColors.border,
    );
  }
}
