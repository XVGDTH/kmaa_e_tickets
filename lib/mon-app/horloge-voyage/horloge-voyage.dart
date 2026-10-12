import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

class HourPicker extends StatelessWidget {
  const HourPicker({
    super.key,
    required this.selectedHour,
    required this.onChanged,
  });

  final int selectedHour; // 0 à 23
  final ValueChanged<int> onChanged;

  static const double _size = 240;
  static const double _radius = 96;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _size - 44,
                height: _size - 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedHour.toString().padLeft(2, '0')}h00',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              for (var h = 0; h < 24; h++) _buildHourDot(h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourDot(int h) {
    final angle = (h / 24) * 2 * math.pi - math.pi / 2;
    final dx = _radius * math.cos(angle);
    final dy = _radius * math.sin(angle);
    final selected = h == selectedHour;

    return Positioned(
      left: _size / 2 + dx - 15,
      top: _size / 2 + dy - 15,
      child: GestureDetector(
        onTap: () => onChanged(h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: selected ? AppColors.buttonGradient : null,
            color: selected ? null : AppColors.background,
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.border,
            ),
          ),
          child: Text(
            '$h',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
