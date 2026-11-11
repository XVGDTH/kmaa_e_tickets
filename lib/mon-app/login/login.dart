import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/authentification/reset_password_screen.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/validators.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/gradient-button.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  int _secondesRestantes = 0;
  Timer? _minuteurVerrouillage;

  @override
  void dispose() {
    _minuteurVerrouillage?.cancel();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _onLogin() async {
  //   FocusManager.instance.primaryFocus?.unfocus();
  //   if (_isLoading) return;
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => _isLoading = true);

  //   // « 70 12 34 56 » et « 70123456 » désignent le même compte.
  //   final telephone = _telephoneController.text.replaceAll(RegExp(r'\D'), '');
  //   final motDePasse = _passwordController.text;

  //   try {
  //     final ok = await ApiService.instance.login(
  //       telephone: telephone,
  //       motDePasse: motDePasse,
  //     );
  //     if (!mounted) return;

  //     if (!ok) {
  //       // Inscription jamais terminée : on envoie un nouveau code et on reprend la vérification.
  //       if (ApiService.instance.derniereErreurCode == 'telephone_non_verifie') {
  //         await ApiService.instance.renvoyerOtp(telephone);
  //         if (!mounted) return;
  //         Navigator.of(context).push(
  //           MaterialPageRoute(
  //             builder: (_) => OtpScreen(
  //               prenom: '',
  //               nom: '',
  //               telephone: telephone,
  //               motDePasse: motDePasse,
  //             ),
  //           ),
  //         );
  //         return;
  //       }
  //       _afficherErreur(
  //         ApiService.instance.derniereErreur ?? 'Identifiants incorrects.',
  //       );
  //       return;
  //     }

  //     final profil = await UserStore.instance.ouvrirSession(
  //       telephone: telephone,
  //     );
  //     if (!mounted) return;

  //     Navigator.of(context).pushNamedAndRemoveUntil(
  //       AppRoutes.home,
  //       (route) => false,
  //       arguments: {'nom': profil.nom, 'prenom': profil.prenom},
  //     );
  //   } on ApiException catch (e) {
  //     if (!mounted) return;
  //     _afficherErreur(e.message);
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _onLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_isLoading || _secondesRestantes > 0) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final telephone = _telephoneController.text.replaceAll(RegExp(r'\D'), '');
    final motDePasse = _passwordController.text;

    try {
      final ok = await ApiService.instance.login(
        telephone: telephone,
        motDePasse: motDePasse,
      );
      if (!mounted) return;

      // 1) Compte verrouillé (6 échecs atteints)
      // if (ApiService.instance.derniereErreurCode ==
      //     'compte_verrouille_otp_requis') {
      //   _afficherErreur(
      //     'Compte verrouillé. Un code WhatsApp vous a été envoyé.',
      //   );
      //   // Affiche l'écran de reset (à créer si tu ne l'as pas encore)
      //   // Navigator.push(...)
      //   return;
      // }
      // 1) Compte verrouillé (4 échecs atteints)
      if (ApiService.instance.compteVerrouilleOtpRequis) {
        setState(
          () {},
        ); // <--- INDISPENSABLE : force Flutter à cacher le formulaire et afficher le blocage
        _afficherErreur(
          'Compte verrouillé. Veuillez changer votre mot de passe.',
        );
        return;
      }

      // 2) Pause de 30s (3 échecs atteints)
      if (ApiService.instance.derniereErreurCode == 'trop_de_tentatives') {
        final delai = ApiService.instance.delaiAvantReessai ?? 30;
        _demarrerCompteARebours(delai);
        _afficherErreur('Trop d\'échecs. Patientez $delai secondes.');
        return;
      }

      // 3) Erreur classique (1 ou 2 échecs)
      // if (!ok) {
      //   _afficherErreur('Attention : identifiants incorrects. Il vous reste ${3 - (ApiService.instance.tentativesRestantes ?? 0)} essai(s) avant la pause.');
      //   return;
      // }
      if (!ok) {
        // Si c'est une pause (3ème tentative)
        if (ApiService.instance.delaiAvantReessai != null) {
          _demarrerCompteARebours(ApiService.instance.delaiAvantReessai!);
          _afficherErreur('Trop de tentatives. Patientez 30 secondes.');
          return;
        }

        // Si le compte vient d'être verrouillé (6ème tentative)
        if (ApiService.instance.compteVerrouilleOtpRequis) {
          setState(() {}); // Force le rebuild pour afficher l'écran de blocage
          _afficherErreur('Compte verrouillé. Changez votre mot de passe.');
          return;
        }

        // Sinon : message d'attention classique
        final restantes = ApiService.instance.tentativesRestantes;
        final msg = restantes != null
            ? 'Attention ! Identifiants incorrects. Il vous reste $restantes essai(s) avant le blocage temporaire.'
            : 'Attention ! Identifiants incorrects.';
        _afficherErreur(msg);
        return;
      }

      // 4) Succès
      final profil = await UserStore.instance.ouvrirSession(
        telephone: telephone,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
        arguments: {'nom': profil.nom, 'prenom': profil.prenom},
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _afficherErreur(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _demarrerCompteARebours(int secondes) {
    _minuteurVerrouillage?.cancel();
    setState(() => _secondesRestantes = secondes);
    _minuteurVerrouillage = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondesRestantes--);
      if (_secondesRestantes <= 0) t.cancel();
    });
  }

  /// Ouvre l'écran de reset (OTP + nouvedeau mdp) et ferme Login à son retour.
  Future<void> _ouvrirResetPassword(String telephone) async {
    // On envoie (ou renvoie) le code juste avant d'ouvrir l'écran.
    try {
      await ApiService.instance.demanderReinitialisation(telephone);
    } catch (_) {
      // Peu importe : l'écran permet de renvoyer le code.
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(telephone: telephone),
      ),
    );
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _onSignUp() {
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  void _onForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header simple avec icône
              const SizedBox(height: 20),
              Center(
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.login_outlined,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
              ),

              // ✅ AJOUT ICI : Espacement pour descendre le formulaire
              const SizedBox(height: 50),

              // Formulaire
              // Formulaire
              Expanded(
                child: _secondesRestantes > 0
                    // 1. ÉCRAN DE PAUSE (30 secondes)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Patientez $_secondesRestantes s...',
                              style: const TextStyle(
                                fontSize: 20,
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    //
                    //
                    //
                    // 2. ÉCRAN DE BLOCAGE (Compte verrouillé)
                    // : ApiService.instance.compteVerrouilleOtpRequis
                    // ? Center(
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         const Icon(
                    //           Icons.lock_outline,
                    //           size: 48,
                    //           color: AppColors.error,
                    //         ),
                    //         const SizedBox(height: 16),
                    //         const Text(
                    //           'Compte temporairement bloqué suite à trop de tentatives.',
                    //           textAlign: TextAlign.center,
                    //           style: TextStyle(
                    //             fontSize: 16,
                    //             color: AppColors.textDark,
                    //           ),
                    //         ),
                    //         const SizedBox(height: 12),
                    //         TextButton(
                    //           onPressed: () {
                    //             Navigator.of(context).pushReplacement(
                    //               MaterialPageRoute(
                    //                 builder: (_) => ResetPasswordScreen(
                    //                   telephone: _telephoneController.text
                    //                       .replaceAll(RegExp(r'\D'), ''),
                    //                 ),
                    //               ),
                    //             );
                    //           },
                    //           child: const Text(
                    //             'Cliquez ici pour changer votre mot de passe',
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w700,
                    //               color: AppColors.accentText,
                    //               decoration: TextDecoration.underline,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   )
                    // 2. ÉCRAN DE BLOCAGE (Compte verrouillé)
                    : ApiService.instance.compteVerrouilleOtpRequis
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_person_outlined,
                                size: 64,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Compte temporairement bloqué',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Suite à de multiples tentatives infructueuses, votre compte est bloqué. Veuillez changer votre mot de passe ou contacter l\'assistance.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // BOUTON RÉINITIALISER
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => ResetPasswordScreen(
                                        telephone: _telephoneController.text
                                            .replaceAll(RegExp(r'\D'), ''),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Changer mon mot de passe par WhatsApp',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentText,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),
                              const Text(
                                "Besoin d'aide immédiate ?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // BOUTONS APPEL ET WHATSAPP
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // APPEL TELEPHONIQUE
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final Uri url = Uri.parse(
                                        'tel:+22664479972',
                                      );
                                      await launchUrl(url);
                                    },
                                    icon: const Icon(
                                      Icons.phone,
                                      color: AppColors.primary,
                                    ),
                                    label: const Text(
                                      'Appeler',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // WHATSAPP
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final Uri url = Uri.parse(
                                        'https://wa.me/22664479972',
                                      );
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.message,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'WhatsApp',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFF25D366,
                                      ), // Vert WhatsApp
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    //
                    // fin du changement
                    //
                    // 3. FORMULAIRE NORMAL (Ton code original)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 10,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - 20,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // --- HAUT DU FORMULAIRE ---
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          "Connexion",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        _buildField(
                                          controller: _telephoneController,
                                          label: 'Numéro de téléphone',
                                          icon: Icons.phone_outlined,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          validator:
                                              Validators.telephoneBurkina,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildField(
                                          controller: _passwordController,
                                          label: 'Mot de passe',
                                          icon: Icons.lock_outline,
                                          obscure: _obscurePassword,
                                          textInputAction: TextInputAction.done,
                                          onToggle: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Entrez votre mot de passe';
                                            }
                                            if (v.length < 4) {
                                              return 'Mot de passe trop court';
                                            }
                                            return null;
                                          },
                                          onSubmitted: (_) => _onLogin(),
                                        ),
                                        const SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: _onForgotPassword,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 2,
                                                vertical: 4,
                                              ),
                                              child: Text(
                                                'Mot de passe oublié ?',
                                                style: TextStyle(
                                                  color: AppColors.accentText,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // --- BAS DU FORMULAIRE (Bouton) ---
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 40.0,
                                        bottom: 20,
                                      ),
                                      child: _buildLoginButton(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── Footer ─────────────

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Pas encore de compte ?",
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          TextButton(
            onPressed: _onSignUp,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "S'inscrire",
              style: TextStyle(
                color: AppColors.accentText,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Formulaire ─────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool? obscure,
    VoidCallback? onToggle,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure ?? false,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 16),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 22),
        suffixIcon: onToggle == null
            ? null
            : IconButton(
                onPressed: onToggle,
                icon: Icon(
                  (obscure ?? false)
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, width: 2),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, width: 2),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  // Widget _buildLoginButton() {
  //   if (_isLoading) {
  //     return Container(
  //       height: 54,
  //       decoration: BoxDecoration(
  //         gradient: AppColors.buttonGradient,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: const Center(
  //         child: SizedBox(
  //           width: 24,
  //           height: 24,
  //           child: CircularProgressIndicator(
  //             strokeWidth: 2.5,
  //             color: AppColors.white,
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return GradientButton(label: 'Se connecter', onPressed: _onLogin);
  // }

  Widget _buildLoginButton() {
    if (_isLoading) {
      return Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.white,
            ),
          ),
        ),
      );
    }

    if (_secondesRestantes > 0) {
      return Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.textMuted.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Patientez $_secondesRestantes s…',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return GradientButton(label: 'Se connecter', onPressed: _onLogin);
  }
}
