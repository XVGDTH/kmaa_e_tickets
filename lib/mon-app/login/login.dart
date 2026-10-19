// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
// import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/validators.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final _formKey = GlobalKey<FormState>();

//   final _telephoneController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _telephoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _onLogin() async {
//     FocusManager.instance.primaryFocus?.unfocus();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     final telephone = _telephoneController.text.trim();

//     try {
//       final ok = await ApiService.instance.login(
//         telephone: telephone,
//         motDePasse: _passwordController.text,
//       );

//       if (!ok) {
//         if (!mounted) return;

//         setState(() {
//           _isLoading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Identifiants incorrects.'),
//             backgroundColor: AppColors.error,
//           ),
//         );

//         return;
//       }

//       final profilActuel = UserStore.instance.profile.value;

//       await UserStore.instance.save(
//         (profilActuel ?? UserProfile(prenom: '', nom: '', telephone: telephone))
//             .copyWith(telephone: telephone, estAuthentifie: true),
//       );

//       if (!mounted) return;

//       final profil = UserStore.instance.profile.value!;

//       Navigator.of(context).pushReplacementNamed(
//         AppRoutes.home,
//         arguments: {'nom': profil.nom, 'prenom': profil.prenom},
//       );
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text(
//             'Une erreur est survenue. Vérifiez votre connexion.',
//           ),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }

//   void _onSignUp() {
//     Navigator.of(context).pushReplacementNamed('/signup');
//   }

//   void _onForgotPassword() {
//     Navigator.of(context).pushNamed('/forgot-password');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final keyboardIsOpen = mediaQuery.viewInsets.bottom > 0;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         // ✅ CORRECTION : On utilise le ROUGE pour le fond sombre
//         // backgroundColor: AppColors.secondary,
//         backgroundColor: AppColors.background,
//         resizeToAvoidBottomInset: true,
//         body: SafeArea(
//           bottom: false,
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final screenHeight = constraints.maxHeight;

//               final topAreaHeight = keyboardIsOpen
//                   ? 120.0
//                   : screenHeight < 650
//                   ? 145.0
//                   : 175.0;

//               final footerHeight = keyboardIsOpen ? 0.0 : 88.0;

//               return Stack(
//                 children: [
//                   // Partie supérieure colorée avec logo.
//                   _buildTopBrand(height: topAreaHeight),

//                   Positioned(
//                     top: topAreaHeight - 8,
//                     left: 0,
//                     right: 0,
//                     bottom: footerHeight,
//                     child: Stack(
//                       children: [
//                         // Contour dessiné le long de la vraie courbe,
//                         // jamais rogné par le découpage de la carte.
//                         Positioned.fill(
//                           child: CustomPaint(
//                             painter: _LoginCardBorderPainter(),
//                           ),
//                         ),
//                         ClipPath(
//                           clipper: _LoginCardClipper(),
//                           child: Container(
//                             color: AppColors.white,
//                             child: SingleChildScrollView(
//                               keyboardDismissBehavior:
//                                   ScrollViewKeyboardDismissBehavior.onDrag,
//                               padding: EdgeInsets.fromLTRB(
//                                 28,
//                                 keyboardIsOpen ? 34 : 38,
//                                 28,
//                                 28,
//                               ),
//                               child: Form(
//                                 key: _formKey,
//                                 child: _buildLoginForm(),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Footer coloré.
//                   if (!keyboardIsOpen)
//                     Positioned(
//                       left: 0,
//                       right: 0,
//                       bottom: 0,
//                       height: footerHeight,
//                       child: _buildFooter(),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBrand({required double height}) {
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       height: height,
//       child: Container(
//         decoration: const BoxDecoration(gradient: AppColors.buttonGradient),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Container(
//               width: 76,
//               height: 76,
//               decoration: const BoxDecoration(
//                 color: AppColors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color(0x33000000),
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ShaderMask(
//                 shaderCallback: (bounds) =>
//                     AppColors.buttonGradient.createShader(bounds),
//                 child: const Icon(
//                   Icons.directions_bus_filled_rounded,
//                   color: AppColors.white,
//                   size: 42,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const SizedBox(height: 8),

//         const Text(
//           'Connexion',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontSize: 25,
//             fontWeight: FontWeight.w700,
//             letterSpacing: -0.3,
//           ),
//         ),

//         const SizedBox(height: 10),

//         const SizedBox(height: 36),

//         // Champ Téléphone
//         _buildUnderlineField(
//           controller: _telephoneController,
//           hintText: 'Numéro de téléphone',
//           keyboardType: TextInputType.phone,
//           textInputAction: TextInputAction.next,
//           validator: Validators.telephoneBurkina,
//         ),

//         const SizedBox(height: 22),

//         // Champ Mot de passe + Lien oublié
//         // Champ Mot de passe
//         _buildUnderlineField(
//           controller: _passwordController,
//           hintText: 'Mot de passe',
//           obscureText: _obscurePassword,
//           textInputAction: TextInputAction.done,
//           onSubmitted: (_) => _onLogin(),
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return 'Entrez votre mot de passe';
//             }
//             if (value.length < 4) {
//               return 'Mot de passe trop court';
//             }
//             return null;
//           },
//           suffixIcon: IconButton(
//             onPressed: () =>
//                 setState(() => _obscurePassword = !_obscurePassword),
//             tooltip: _obscurePassword
//                 ? 'Afficher le mot de passe'
//                 : 'Masquer le mot de passe',
//             splashRadius: 20,
//             icon: Icon(
//               _obscurePassword
//                   ? Icons.visibility_off_outlined
//                   : Icons.visibility_outlined,
//               color: AppColors.textMuted,
//               size: 19,
//             ),
//           ),
//         ),

//         const SizedBox(height: 8),

//         // Lien oublié, bien aligné sous le champ
//         Align(
//           alignment: Alignment.centerRight,
//           child: InkWell(
//             onTap: _onForgotPassword,
//             borderRadius: BorderRadius.circular(4),
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
//               child: Text(
//                 'Mot de passe oublié ?',
//                 style: TextStyle(
//                   color: AppColors.secondary,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(height: 18),

//         _buildLoginButton(),

//         const SizedBox(height: 26),
//       ],
//     );
//   }

//   Widget _buildUnderlineField({
//     required TextEditingController controller,
//     required String hintText,
//     required String? Function(String?) validator,
//     TextInputType? keyboardType,
//     TextInputAction textInputAction = TextInputAction.next,
//     bool obscureText = false,
//     ValueChanged<String>? onSubmitted,
//     Widget? suffixIcon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       validator: validator,
//       keyboardType: keyboardType,
//       textInputAction: textInputAction,
//       onFieldSubmitted: onSubmitted,
//       // ✅ CORRECTION : Curseur en Ambre (primary)
//       cursorColor: AppColors.secondary,
//       style: const TextStyle(
//         color: AppColors.textDark,
//         fontSize: 15,
//         fontWeight: FontWeight.w500,
//       ),
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: const TextStyle(
//           color: AppColors.textMuted,
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//         ),
//         prefixIcon: hintText.contains('téléphone')
//             ? const Icon(
//                 Icons.phone_outlined,
//                 color: AppColors.textMuted,
//                 size: 20,
//               )
//             : const Icon(
//                 Icons.lock_outline,
//                 color: AppColors.textMuted,
//                 size: 20,
//               ),
//         prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),

//         errorStyle: const TextStyle(
//           color: AppColors.error,
//           fontSize: 11,
//           height: 1.2,
//         ),

//         contentPadding: const EdgeInsets.only(
//           left: 0,
//           right: 0,
//           top: 12,
//           bottom: 12,
//         ),

//         border: const UnderlineInputBorder(
//           borderSide: BorderSide(color: AppColors.border, width: 1),
//         ),
//         enabledBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: AppColors.border, width: 1),
//         ),
//         // ✅ CORRECTION : Focus en Ambre (primary)
//         focusedBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: AppColors.primary, width: 2),
//         ),
//         errorBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: AppColors.error, width: 1),
//         ),
//         focusedErrorBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: AppColors.error, width: 2),
//         ),
//         suffixIcon: suffixIcon,
//         suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
//       ),
//     );
//   }

//   Widget _buildLoginButton() {
//     return SizedBox(
//       height: 48,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _onLogin,
//         style: ElevatedButton.styleFrom(
//           // ✅ CORRECTION : On utilise le dégradé de ta charte
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           padding: EdgeInsets.zero,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         child: Ink(
//           decoration: BoxDecoration(
//             // Dégradé Ambre → Rouge défini dans ta charte
//             gradient: AppColors.buttonGradient,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Container(
//             alignment: Alignment.center,
//             child: _isLoading
//                 ? const SizedBox(
//                     width: 22,
//                     height: 22,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2.2,
//                       color: AppColors.white,
//                     ),
//                   )
//                 : const Text(
//                     'Se connecter',
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFooter() {
//     return Container(
//       decoration: const BoxDecoration(gradient: AppColors.buttonGradient),
//       child: Center(
//         child: InkWell(
//           onTap: _onSignUp,
//           borderRadius: BorderRadius.circular(8),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//             child: RichText(
//               textAlign: TextAlign.center,
//               text: const TextSpan(
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 children: [
//                   TextSpan(text: 'Vous n\u2019avez pas encore de compte ? '),
//                   TextSpan(
//                     text: 'Créer un compte',
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontWeight: FontWeight.w800,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Forme blanche asymétrique inspirée de tes calculs.
// class _LoginCardClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final width = size.width;
//     final height = size.height;

//     final path = Path();

//     path.moveTo(0, 78);
//     path.cubicTo(0, 28, 34, 0, 88, 0);
//     path.lineTo(width, 0);
//     path.lineTo(width, height - 75);
//     path.cubicTo(width, height - 25, width - 36, height, width - 88, height);
//     path.lineTo(0, height);
//     path.close();

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }

// /// Dessine le contour de la carte en suivant exactement la même courbe
// /// que _LoginCardClipper — contrairement à un simple Border, ce tracé
// /// n'est jamais rogné par le ClipPath.

// class _LoginCardBorderPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final path = _LoginCardClipper().getClip(size);

//     // Halo blanc qui sépare le contour coloré du dégradé.
//     final halo = Paint()
//       ..color = AppColors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 6;
//     canvas.drawPath(path, halo);

//     // Contour coloré, par-dessus le halo.
//     final paint = Paint()
//       ..color = AppColors.secondary
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.5;
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/authentification/formulaire_otp.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/validators.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/gradient-button.dart';

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

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // « 70 12 34 56 » et « 70123456 » désignent le même compte.
    final telephone = _telephoneController.text.replaceAll(RegExp(r'\D'), '');
    final motDePasse = _passwordController.text;

    try {
      final ok = await ApiService.instance.login(
        telephone: telephone,
        motDePasse: motDePasse,
      );
      if (!mounted) return;

      if (!ok) {
        // Inscription jamais terminée : on envoie un nouveau code et on reprend la vérification.
        if (ApiService.instance.derniereErreurCode == 'telephone_non_verifie') {
          await ApiService.instance.renvoyerOtp(telephone);
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                prenom: '',
                nom: '',
                telephone: telephone,
                motDePasse: motDePasse,
              ),
            ),
          );
          return;
        }
        _afficherErreur(
          ApiService.instance.derniereErreur ?? 'Identifiants incorrects.',
        );
        return;
      }

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

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
  //
  //
  //

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
              Expanded(
                child: LayoutBuilder(
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // --- HAUT DU FORMULAIRE ---
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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

                                  // Champ Téléphone
                                  _buildField(
                                    controller: _telephoneController,
                                    label: 'Numéro de téléphone',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    validator: Validators.telephoneBurkina,
                                  ),
                                  const SizedBox(height: 16),

                                  // Champ Mot de passe
                                  _buildField(
                                    controller: _passwordController,
                                    label: 'Mot de passe',
                                    icon: Icons.lock_outline,
                                    obscure: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onToggle: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
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

                                  // Lien Mot de passe oublié
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: _onForgotPassword,
                                      borderRadius: BorderRadius.circular(4),
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

    return GradientButton(label: 'Se connecter', onPressed: _onLogin);
  }
}
