import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/validators.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
import 'package:kmaa_e_tickets/mon-app/widgets/loading_button.dart';

/// Écran affiché quand le compte est verrouillé après trop d'échecs de login.
/// L'utilisateur saisit le code WhatsApp puis un nouveau mot de passe.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.telephone});

  final String telephone;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _mdpController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  String? _erreur;
  int _attente = 30;
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    _demarrerAttente();
  }

  void _demarrerAttente() {
    _minuteur?.cancel();
    _attente = 30;
    _minuteur = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _attente--);
      if (_attente <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    _codeController.dispose();
    _mdpController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _renvoyer() async {
    setState(() => _erreur = null);
    try {
      await ApiService.instance.demanderReinitialisation(widget.telephone);
      if (!mounted) return;
      setState(_demarrerAttente);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Un nouveau code vient d\'être envoyé.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erreur = e.message);
    }
  }

  Future<void> _valider() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_loading) return;

    setState(() {
      _loading = true;
      _erreur = null;
    });

    try {
      final ok = await ApiService.instance.reinitialiserMotDePasse(
        telephone: widget.telephone,
        code: _codeController.text.trim(),
        motDePasse: _mdpController.text,
      );
      if (!mounted) return;

      if (!ok) {
        setState(() {
          _erreur = ApiService.instance.derniereErreur ?? 'Code incorrect.';
        });
        return;
      }

      // Session ouverte : on enregistre le profil local puis on va à l'accueil.
      final profil = await UserStore.instance.ouvrirSession(
        telephone: widget.telephone,
      );
      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
        arguments: {'nom': profil.nom, 'prenom': profil.prenom},
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          foregroundColor: AppColors.textDark,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_reset,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Compte verrouillé',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Un code à 6 chiffres a été envoyé par WhatsApp au ${widget.telephone}. '
                    'Saisissez-le avec votre nouveau mot de passe.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
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
                      labelText: 'Code WhatsApp',
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    validator: (v) {
                      if ((v ?? '').trim().length != 6) {
                        return 'Entrez les 6 chiffres du code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mdpController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: Validators.motDePasse,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    validator: (v) => Validators.confirmationMotDePasse(
                      v,
                      _mdpController.text,
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
                  const SizedBox(height: 20),
                  LoadingButton(
                    label: 'Valider le nouveau mot de passe',
                    loading: _loading,
                    onPressed: _valider,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: (_attente > 0 || _loading) ? null : _renvoyer,
                      child: Text(
                        _attente > 0
                            ? 'Renvoyer le code dans $_attente s'
                            : 'Renvoyer le code',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
