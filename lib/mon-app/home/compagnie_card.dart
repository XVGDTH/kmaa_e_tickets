import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';

class CompagnieCard extends StatelessWidget {
  const CompagnieCard({
    super.key,
    required this.compagnie,
    required this.days,
    required this.selectedDay,
    required this.onDaySelected,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  final Compagnie compagnie;
  final List<DateTime> days;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  static const _dayLetters = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: AppColors.buttonGradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.white.withOpacity(0.20),
            highlightColor: AppColors.white.withOpacity(0.08),
            child: SizedBox(
              height: 214,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 136, child: _buildImage()),
                        Expanded(child: _buildInfo()),
                      ],
                    ),
                  ),
                  _buildDayStrip(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────── Image ─────────────

  Widget _buildImage() {
    final placeholder = Center(
      child: Icon(
        Icons.directions_bus_rounded,
        size: 60,
        color: AppColors.white.withOpacity(0.75),
      ),
    );

    final path = compagnie.image;
    if (path == null) return placeholder;

    return Image.asset(
      path,
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stack) => placeholder,
    );
  }

  // ───────────── Infos (étiquettes, nom, note) ─────────────

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final t in compagnie.tags) _buildTag(t)],
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onFavorite,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0x40000000),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            compagnie.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          if (compagnie.rating != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  compagnie.rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x40000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ───────────── Bande des jours ─────────────

  Widget _buildDayStrip() {
    return Container(
      height: 62,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++) Expanded(child: _buildDay(i)),
        ],
      ),
    );
  }

  Widget _buildDay(int index) {
    final selected = index == selectedDay;
    final date = days[index];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onDaySelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _dayLetters[date.weekday - 1],
              style: TextStyle(
                color: selected
                    ? AppColors.secondary
                    : AppColors.textOnDarkMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                color: selected ? AppColors.secondary : AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
