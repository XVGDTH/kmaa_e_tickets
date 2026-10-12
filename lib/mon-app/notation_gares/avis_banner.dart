import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/formulaire_notation.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/service-rappel.dart';

class AvisBanner extends StatelessWidget {
  const AvisBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Billet>>(
      valueListenable: AlertService.instance.avisADonner,
      builder: (context, liste, _) {
        if (liste.isEmpty) return const SizedBox.shrink();
        final b = liste.first;
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Comment s\'est passé votre trajet ${b.compagnie.name} ?',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NotationGareScreen(billet: b),
                  ),
                ),
                child: const Text(
                  'Noter',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
