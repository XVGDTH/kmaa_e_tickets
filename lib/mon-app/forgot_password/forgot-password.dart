import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/validators.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
import 'package:kmaa_e_tickets/mon-app/widgets/loading_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formNumero = GlobalKey<FormState>();
  final _formCode = GlobalKey<FormState>();
  final _telController = TextEditingController();
  final _codeController = TextEditingController();
  final _mdpController = TextEditingController();
  final _confirmController = TextEditingController();

  int _etape =
      0; // 0 : numéro de téléphone, 1 : code reçu + nouveau mot de passe
  bool _loading = false;
  bool _masquer = true;
  String? _erreur;

  String get _telephone => _telController.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _telController.dispose();
    _codeController.dispose();
    _mdpController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _envoyerCode({bool renvoi = false}) async {
    if (!renvoi && !(_formNumero.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _erreur = null;
    });
    try {
      await ApiService.instance.demanderReinitialisation(_telephone);
      if (!mounted) return;
      if (renvoi) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Un nouveau code vient d\'être envoyé.'),
          ),
        );
      } else {
        setState(() => _etape = 1);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _valider() async {
    if (!(_formCode.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _erreur = null;
    });
    try {
      final ok = await ApiService.instance.reinitialiserMotDePasse(
        telephone: _telephone,
        code: _codeController.text.trim(),
        motDePasse: _mdpController.text,
      );
      if (!mounted) return;

      if (!ok) {
        setState(
          () => _erreur =
              ApiService.instance.derniereErreur ?? 'Code incorrect ou expiré.',
        );
        return;
      }

      final profil = await UserStore.instance.ouvrirSession(
        telephone: _telephone,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
        arguments: {'nom': profil.nom, 'prenom': profil.prenom},
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _retour() {
    if (_etape == 1) {
      setState(() {
        _etape = 0;
        _erreur = null;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: _loading ? null : _retour,
                  icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _etape == 0 ? 'Mot de passe oublié' : 'Nouveau mot de passe',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _etape == 0
                      ? 'Entrez votre numéro WhatsApp : nous vous envoyons un code pour choisir un nouveau mot de passe.'
                      : 'Un code à 6 chiffres a été envoyé au $_telephone. Entrez-le puis choisissez votre nouveau mot de passe.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 28),
                if (_etape == 0) _buildEtapeNumero() else _buildEtapeCode(),
                if (_erreur != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _erreur!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEtapeNumero() {
    return Form(
      key: _formNumero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _champ(
            controller: _telController,
            label: 'Numéro WhatsApp',
            icone: Icons.chat_bubble_outline,
            type: TextInputType.phone,
            validator: Validators.telephoneBurkina,
          ),
          const SizedBox(height: 24),
          LoadingButton(
            label: 'Recevoir le code',
            loading: _loading,
            onPressed: () => _envoyerCode(),
          ),
        ],
      ),
    );
  }

  Widget _buildEtapeCode() {
    return Form(
      key: _formCode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _champ(
            controller: _codeController,
            label: 'Code reçu (6 chiffres)',
            icone: Icons.pin_outlined,
            type: TextInputType.number,
            maxLength: 6,
            validator: (v) => RegExp(r'^\d{6}$').hasMatch((v ?? '').trim())
                ? null
                : 'Entrez les 6 chiffres du code',
          ),
          const SizedBox(height: 16),
          _champ(
            controller: _mdpController,
            label: 'Nouveau mot de passe',
            icone: Icons.lock_outline,
            masque: _masquer,
            validator: Validators.motDePasse,
            suffixe: IconButton(
              onPressed: () => setState(() => _masquer = !_masquer),
              icon: Icon(
                _masquer
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _champ(
            controller: _confirmController,
            label: 'Confirmer le mot de passe',
            icone: Icons.lock_outline,
            masque: _masquer,
            validator: (v) =>
                Validators.confirmationMotDePasse(v, _mdpController.text),
          ),
          const SizedBox(height: 24),
          LoadingButton(
            label: 'Valider',
            loading: _loading,
            onPressed: _valider,
          ),
          Center(
            child: TextButton(
              onPressed: _loading ? null : () => _envoyerCode(renvoi: true),
              child: const Text('Renvoyer le code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _champ({
    required TextEditingController controller,
    required String label,
    required IconData icone,
    required String? Function(String?) validator,
    TextInputType? type,
    bool masque = false,
    int? maxLength,
    Widget? suffixe,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: type,
      obscureText: masque,
      maxLength: maxLength,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 16),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 13),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        prefixIcon: Icon(icone, color: AppColors.textMuted, size: 22),
        suffixIcon: suffixe,
        border: _bordure(AppColors.border),
        enabledBorder: _bordure(AppColors.border),
        focusedBorder: _bordure(AppColors.primary, largeur: 2),
        errorBorder: _bordure(AppColors.error),
        focusedErrorBorder: _bordure(AppColors.error, largeur: 2),
      ),
    );
  }

  OutlineInputBorder _bordure(Color couleur, {double largeur = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: couleur, width: largeur),
      );
}
