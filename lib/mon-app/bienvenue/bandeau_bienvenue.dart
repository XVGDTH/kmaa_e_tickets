import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';

/// Vrai juste après la première vérification du compte : l'accueil montre alors le message de bienvenue.
class Bienvenue {
  Bienvenue._();
  static final ValueNotifier<bool> afficher = ValueNotifier<bool>(false);
}

class BandeauBienvenue extends StatelessWidget {
  const BandeauBienvenue({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Bienvenue.afficher,
      builder: (context, visible, _) {
        if (!visible) return const SizedBox.shrink();

        final prenom = UserStore.instance.profile.value?.prenom ?? '';

        return Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.celebration_rounded,
                color: AppColors.white,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prenom.isEmpty ? 'Bienvenue !' : 'Bienvenue, $prenom !',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Réservez vos trajets en toute simplicité, où que vous soyez au Burkina.',
                      style: TextStyle(color: AppColors.white, fontSize: 12.5),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/notifications'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Voir mes notifications',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Bienvenue.afficher.value = false,
                icon: const Icon(Icons.close, color: AppColors.white, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}
