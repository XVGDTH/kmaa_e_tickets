import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/service-rappel.dart';

class ReminderBanner extends StatelessWidget {
  const ReminderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Billet?>(
      valueListenable: AlertService.instance.rappelDuJour,
      builder: (context, b, _) {
        if (b == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Voyage à venir : ${b.compagnie.name} le ${b.dateVoyage.day}/${b.dateVoyage.month} à ${b.heure}.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                onTap: AlertService.instance.effacerRappelDuJour,
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}
