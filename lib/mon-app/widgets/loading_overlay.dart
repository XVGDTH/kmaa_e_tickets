import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.secondary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
