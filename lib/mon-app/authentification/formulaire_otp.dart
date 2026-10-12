import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
import 'package:kmaa_e_tickets/mon-app/utilisateurs/utilisateur.dart'
    hide UserStore, UserProfile;
import 'package:kmaa_e_tickets/mon-app/widgets/loading_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.motDePasse,
    this.otpDemo,
  });

  final String prenom;
  final String nom;
  final String telephone;
  final String motDePasse;

  /// Présent uniquement en mode démo (pas de vrai WhatsApp branché).
  final String? otpDemo;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _erreur;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifier() async {
    setState(() {
      _loading = true;
      _erreur = null;
    });
    final ok = await ApiService.instance.verifierOtp(
      telephone: widget.telephone,
      code: _codeController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      setState(
        () => _erreur = 'Code incorrect. Vérifiez le message WhatsApp reçu.',
      );
      return;
    }

    await UserStore.instance.save(
      UserProfile(
        prenom: widget.prenom,
        nom: widget.nom,
        telephone: widget.telephone,
        motDePasseHash: hasherMotDePasse(widget.motDePasse),
        estAuthentifie: true,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
      arguments: {'nom': widget.nom, 'prenom': widget.prenom},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Vérification WhatsApp',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Un code à 6 chiffres a été envoyé par WhatsApp au ${widget.telephone}. Copiez-le ci-dessous.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                if (widget.otpDemo != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'votre code est le : ${widget.otpDemo}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _erreur!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Vérifier',
                  loading: _loading,
                  onPressed: _verifier,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
