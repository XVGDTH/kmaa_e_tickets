import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

/// Bouton principal avec état de chargement intégré : évite le double
/// clic et donne un retour visuel immédiat pendant une opération
/// asynchrone (paiement, écriture en base, etc.).
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.loading,
    this.enabled = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final double height;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !loading && onPressed != null;
    final radius = BorderRadius.circular(8);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: canTap || loading ? AppColors.buttonGradient : null,
          color: canTap || loading ? null : AppColors.border,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: canTap ? onPressed : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: (canTap || loading)
                            ? AppColors.white
                            : AppColors.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
