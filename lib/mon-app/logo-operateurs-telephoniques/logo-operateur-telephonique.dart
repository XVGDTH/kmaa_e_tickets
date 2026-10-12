import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

/// Affiche un logo depuis les assets, ou depuis une URL si [source]
/// commence par 'http'. Une icône de repli s'affiche si l'image est
/// absente ou ne charge pas.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    required this.source,
    this.size = 40,
    this.fallbackIcon = Icons.account_balance_wallet_outlined,
    this.fallbackColor,
  });

  final String source;
  final double size;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      fallbackIcon,
      size: size * 0.6,
      color: fallbackColor ?? AppColors.textMuted,
    );
    final isNetwork = source.startsWith('http');

    return SizedBox(
      width: size,
      height: size,
      child: isNetwork
          ? Image.network(
              source,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
            )
          : Image.asset(
              source,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}
