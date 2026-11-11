import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

const String kTexteOffres =
    'Je souhaite recevoir par WhatsApp les offres et nouveautés des compagnies que j\'utilise. '
    'Je peux me désabonner à tout moment en répondant STOP.';

/// Choix fait à l'inscription, transmis au serveur une fois le compte vérifié (écran du code OTP).
class ChoixOffres {
  ChoixOffres._();
  static bool accepte = false;

  static Future<void> envoyerSiNecessaire() async {
    if (!accepte) return;
    try {
      await ApiService.instance.definirMarketing(true, source: 'inscription');
      accepte = false;
    } catch (_) {
      // sans réseau : la question sera reposée dans l'application
    }
  }
}

/// Case à cocher de l'inscription : jamais cochée d'office.
class CaseOffresWhatsapp extends StatefulWidget {
  const CaseOffresWhatsapp({super.key});

  @override
  State<CaseOffresWhatsapp> createState() => _CaseOffresWhatsappState();
}

class _CaseOffresWhatsappState extends State<CaseOffresWhatsapp> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: ChoixOffres.accepte,
            activeColor: AppColors.accentText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.textMuted, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (v) => setState(() => ChoixOffres.accepte = v ?? false),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            kTexteOffres,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

/// Réglage du profil : un interrupteur par canal ('whatsapp' ou 'app').
class TuileOffres extends StatefulWidget {
  const TuileOffres({
    super.key,
    required this.canal,
    required this.titre,
    required this.sousTitre,
    required this.icone,
  });

  final String canal;
  final String titre;
  final String sousTitre;
  final IconData icone;

  @override
  State<TuileOffres> createState() => _TuileOffresState();
}

class _TuileOffresState extends State<TuileOffres> {
  bool _valeur = false;
  bool _envoi = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final e = await ApiService.instance.etatMarketing();
      if (mounted) {
        setState(() => _valeur = widget.canal == 'app' ? e.app : e.accepte);
      }
    } catch (_) {
      // l'interrupteur reste utilisable ; le serveur confirmera au premier changement
    }
  }

  Future<void> _changer(bool v) async {
    final avant = _valeur;
    setState(() {
      _valeur = v;
      _envoi = true;
    });

    try {
      await ApiService.instance.definirMarketing(
        v,
        source: 'profil',
        canal: widget.canal,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _valeur = avant);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException
                  ? e.message
                  : 'Changement impossible. Vérifiez votre connexion.',
            ),
          ),
        );
      }
    }

    if (mounted) setState(() => _envoi = false);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: _valeur,
      onChanged: _envoi ? null : _changer,
      activeThumbColor: AppColors.secondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      secondary: Icon(widget.icone, size: 20, color: AppColors.textMuted),
      title: Text(
        widget.titre,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(widget.sousTitre, style: const TextStyle(fontSize: 12)),
    );
  }
}

/// Question posée une seule fois aux clients qui n'ont jamais répondu.
class PromptOffres {
  PromptOffres._();

  static Future<void> afficherSiNecessaire(BuildContext context) async {
    try {
      final etat = await ApiService.instance.etatMarketing();
      if (etat.dejaRepondu || !context.mounted) return;

      final oui = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Recevoir les bons plans ?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(kTexteOffres),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Non merci'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Oui, je veux'),
            ),
          ],
        ),
      );

      await ApiService.instance.definirMarketing(
        oui ?? false,
        source: 'invite',
      );
    } catch (_) {
      // sans réseau : on reposera la question plus tard
    }
  }
}
