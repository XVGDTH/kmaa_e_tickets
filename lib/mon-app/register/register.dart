// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
// import 'package:kmaa_e_tickets/mon-app/authentification/formulaire_otp.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/assets-constantes.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/app-string-constantes.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/gradient-button.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/validators.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _lastNameController = TextEditingController();
//   final _firstNameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmController = TextEditingController();
//   final _telephoneController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;
//   bool _acceptedTerms = false;

//   @override
//   void dispose() {
//     _lastNameController.dispose();
//     _firstNameController.dispose();
//     _passwordController.dispose();
//     _confirmController.dispose();
//     _telephoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _onSignUp() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_acceptedTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Veuillez accepter les termes et conditions.'),
//         ),
//       );
//       return;
//     }

//     final nom = _lastNameController.text.trim();
//     final prenom = _firstNameController.text.trim();
//     final telephone = _telephoneController.text.trim();
//     final motDePasse = _passwordController.text;

//     final result = await ApiService.instance.register(
//       prenom: prenom,
//       nom: nom,
//       telephone: telephone,
//       motDePasse: motDePasse,
//     );

//     if (!mounted) return;
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => OtpScreen(
//           prenom: prenom,
//           nom: nom,
//           telephone: telephone,
//           motDePasse: motDePasse,
//           otpDemo: result['otpDemo'] as String?,
//         ),
//       ),
//     );
//   }

//   void _onSignIn() {
//     Navigator.of(context).pushReplacementNamed('/login');
//   }

//   void _onSocialTap(String provider) {
//     // TODO: connexion via Apple / Facebook / Google.
//     debugPrint('Inscription via $provider');
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Quand le clavier est ouvert, on libère de la place pour le formulaire.
//     final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.dark,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: Stack(
//           children: [
//             _buildTopWave(),
//             if (!keyboardOpen) _buildBottomWave(),
//             SafeArea(
//               child: Column(
//                 children: [
//                   _buildHeader(), // fixe : ne défile jamais
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildField(
//                               controller: _lastNameController,
//                               label: AppStrings.lastNameHint,
//                               icon: Icons.person_outline,
//                               textCapitalization: TextCapitalization.words,
//                               keyboardType: TextInputType.name,
//                               validator: (v) {
//                                 if (v == null || v.trim().isEmpty) {
//                                   return 'Entrez votre nom';
//                                 }
//                                 if (v.trim().length < 2) {
//                                   return 'Minimum 2 caractères';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             _buildField(
//                               controller: _firstNameController,
//                               label: AppStrings.firstNameHint,
//                               icon: Icons.badge_outlined,
//                               textCapitalization: TextCapitalization.words,
//                               keyboardType: TextInputType.name,
//                               validator: (v) {
//                                 if (v == null || v.trim().isEmpty) {
//                                   return 'Entrez votre prénom';
//                                 }
//                                 if (v.trim().length < 2) {
//                                   return 'Minimum 2 caractères';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             _buildField(
//                               controller: _telephoneController,
//                               label: 'Numéro WhatsApp',
//                               icon: Icons.chat_bubble_outline,
//                               keyboardType: TextInputType.phone,
//                               validator: Validators.telephoneBurkina,
//                             ),
//                             const SizedBox(height: 16),
//                             _buildField(
//                               controller: _passwordController,
//                               label: AppStrings.passwordHint,
//                               icon: Icons.lock_outline,
//                               obscure: _obscurePassword,
//                               onToggle: () => setState(
//                                 () => _obscurePassword = !_obscurePassword,
//                               ),
//                               validator: (v) {
//                                 if (v == null || v.isEmpty) {
//                                   return 'Entrez un mot de passe';
//                                 }
//                                 if (v.length < 6) return 'Minimum 6 caractères';
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             _buildField(
//                               controller: _confirmController,
//                               label: AppStrings.confirmPasswordHint,
//                               icon: Icons.lock_outline,
//                               obscure: _obscureConfirm,
//                               textInputAction: TextInputAction.done,
//                               onToggle: () => setState(
//                                 () => _obscureConfirm = !_obscureConfirm,
//                               ),
//                               validator: (v) {
//                                 if (v == null || v.isEmpty) {
//                                   return 'Confirmez votre mot de passe';
//                                 }
//                                 if (v != _passwordController.text) {
//                                   return 'Les mots de passe ne correspondent pas';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 18),
//                             _buildTermsRow(),
//                             const SizedBox(height: 24),
//                             _buildSignUpButton(),
//                             const SizedBox(height: 26),
//                             _buildDivider(),
//                             const SizedBox(height: 20),
//                             _buildSocialRow(),
//                             const SizedBox(height: 8),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (!keyboardOpen) _buildFooter(), // fixe : ne défile jamais
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ───────────── En-tête et pied de page fixes ─────────────

//   Widget _buildHeader() {
//     return const SizedBox(
//       height: 170,
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Padding(
//           padding: EdgeInsets.only(left: 28, bottom: 40),
//           child: Text(
//             AppStrings.signUpTitle,
//             style: TextStyle(
//               color: AppColors.textDark,
//               fontSize: 32,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFooter() {
//     return SizedBox(
//       height: 120,
//       child: Center(
//         child: Material(
//           color: AppColors.white,
//           elevation: 4,
//           shadowColor: Colors.black45,
//           borderRadius: BorderRadius.circular(30),
//           child: InkWell(
//             onTap: _onSignIn,
//             borderRadius: BorderRadius.circular(30),
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               child: Text.rich(
//                 TextSpan(
//                   style: TextStyle(color: AppColors.textDark, fontSize: 17),
//                   children: [
//                     TextSpan(text: AppStrings.alreadyAccount),
//                     TextSpan(
//                       text: AppStrings.signIn,
//                       style: TextStyle(
//                         color: AppColors.accentText,
//                         fontWeight: FontWeight.w800,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ───────────── Vagues décoratives ─────────────

//   Widget _buildTopWave() {
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: ClipPath(
//         clipper: _TopWaveClipper(),
//         child: Container(
//           height: 200,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topRight,
//               end: Alignment.bottomLeft,
//               colors: [AppColors.secondary, AppColors.primary],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomWave() {
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: ClipPath(
//         clipper: _BottomWaveClipper(),
//         child: Container(
//           height: 120,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.bottomLeft,
//               end: Alignment.topRight,
//               colors: [AppColors.secondary, AppColors.primary],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ───────────── Formulaire ─────────────

//   /// Champ générique : si [obscure] est renseigné, c'est un champ mot de passe
//   /// avec bouton œil.
//   Widget _buildField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String? Function(String?) validator,
//     TextInputType? keyboardType,
//     TextInputAction textInputAction = TextInputAction.next,
//     TextCapitalization textCapitalization = TextCapitalization.none,
//     bool? obscure,
//     VoidCallback? onToggle,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscure ?? false,
//       validator: validator,
//       keyboardType: keyboardType,
//       textInputAction: textInputAction,
//       textCapitalization: textCapitalization,
//       style: const TextStyle(color: AppColors.textDark, fontSize: 18),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 17),
//         floatingLabelStyle: const TextStyle(
//           color: AppColors.accentText,
//           fontSize: 18,
//           fontWeight: FontWeight.w700,
//         ),
//         errorStyle: const TextStyle(
//           color: AppColors.error,
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//         ),
//         filled: true,
//         fillColor: AppColors.white,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 18,
//         ),
//         prefixIcon: Icon(icon, color: AppColors.textMuted, size: 24),
//         suffixIcon: onToggle == null
//             ? null
//             : IconButton(
//                 onPressed: onToggle,
//                 tooltip: (obscure ?? false)
//                     ? 'Afficher le mot de passe'
//                     : 'Masquer le mot de passe',
//                 icon: Icon(
//                   (obscure ?? false)
//                       ? Icons.visibility_off_outlined
//                       : Icons.visibility_outlined,
//                   color: AppColors.textMuted,
//                   size: 26,
//                 ),
//               ),
//         border: _border(AppColors.border),
//         enabledBorder: _border(AppColors.border),
//         focusedBorder: _border(AppColors.primary, width: 2.5),
//         errorBorder: _border(AppColors.error),
//         focusedErrorBorder: _border(AppColors.error, width: 2.5),
//       ),
//     );
//   }

//   OutlineInputBorder _border(Color color, {double width = 1.5}) =>
//       OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: color, width: width),
//       );

//   Widget _buildTermsRow() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: 32,
//           height: 32,
//           child: Transform.scale(
//             scale: 1.3,
//             child: Checkbox(
//               value: _acceptedTerms,
//               activeColor: AppColors.accentText,
//               side: const BorderSide(color: AppColors.textMuted, width: 2),
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         const Expanded(
//           child: Text.rich(
//             TextSpan(
//               style: TextStyle(color: AppColors.textDark, fontSize: 15),
//               children: [
//                 TextSpan(text: AppStrings.acceptTermsPrefix),
//                 TextSpan(
//                   text: AppStrings.termsAndConditions,
//                   style: TextStyle(
//                     color: AppColors.accentText,
//                     fontWeight: FontWeight.w700,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSignUpButton() {
//     return GradientButton(
//       label: AppStrings.signUpButton, // « Créer mon compte »
//       onPressed: _onSignUp,
//     );
//   }

//   // ───────────── Réseaux sociaux ─────────────

//   Widget _buildDivider() {
//     return const Row(
//       children: [
//         Expanded(child: Divider(color: AppColors.border, thickness: 1.5)),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 12),
//           child: Text(
//             AppStrings.orSignUpWith,
//             style: TextStyle(
//               color: AppColors.textMuted,
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         Expanded(child: Divider(color: AppColors.border, thickness: 1.5)),
//       ],
//     );
//   }

//   Widget _buildSocialRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _socialButton(AppAssets.appleIconUrl, Icons.apple, 'Apple'),
//         _socialButton(AppAssets.facebookIconUrl, Icons.facebook, 'Facebook'),
//         _socialButton(AppAssets.googleIconUrl, Icons.g_mobiledata, 'Google'),
//       ],
//     );
//   }

//   Widget _socialButton(String url, IconData fallback, String provider) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Material(
//           color: AppColors.white,
//           elevation: 3,
//           shadowColor: Colors.black45,
//           shape: const CircleBorder(
//             side: BorderSide(color: AppColors.border, width: 1.5),
//           ),
//           child: InkWell(
//             onTap: () => _onSocialTap(provider),
//             customBorder: const CircleBorder(),
//             child: SizedBox(
//               width: 64,
//               height: 64,
//               child: Center(
//                 child: Image.network(
//                   url,
//                   width: 36,
//                   height: 36,
//                   fit: BoxFit.contain,
//                   loadingBuilder: (context, child, progress) => progress == null
//                       ? child
//                       : const SizedBox(width: 36, height: 36),
//                   errorBuilder: (context, error, stack) =>
//                       Icon(fallback, size: 36, color: AppColors.textDark),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           provider,
//           style: const TextStyle(
//             color: AppColors.textDark,
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ───────────── Clippers des vagues ─────────────

// class _TopWaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final w = size.width;
//     final h = size.height;
//     return Path()
//       ..lineTo(0, h * 0.55)
//       ..quadraticBezierTo(w * 0.5, h * 1.2, w, h * 0.5)
//       ..lineTo(w, 0)
//       ..close();
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }

// class _BottomWaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final w = size.width;
//     final h = size.height;
//     return Path()
//       ..moveTo(0, h * 0.3)
//       ..cubicTo(w * 0.2, 0, w * 0.5, h * 0.12, w * 0.7, h * 0.4)
//       ..quadraticBezierTo(w * 0.85, h * 0.62, w, h * 0.78)
//       ..lineTo(w, h)
//       ..lineTo(0, h)
//       ..close();
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/authentification/formulaire_otp.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/assets-constantes.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/app-string-constantes.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/gradient-button.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _telephoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les termes et conditions.'),
        ),
      );
      return;
    }

    final nom = _lastNameController.text.trim();
    final prenom = _firstNameController.text.trim();
    final telephone = _telephoneController.text.trim();
    final motDePasse = _passwordController.text;

    final result = await ApiService.instance.register(
      prenom: prenom,
      nom: nom,
      telephone: telephone,
      motDePasse: motDePasse,
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          prenom: prenom,
          nom: nom,
          telephone: telephone,
          motDePasse: motDePasse,
          otpDemo: result['otpDemo'] as String?,
        ),
      ),
    );
  }

  void _onSignIn() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _onSocialTap(String provider) {
    debugPrint('Inscription via $provider');
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
                    Icons.person_add_alt_1_outlined,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Formulaire
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 10,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Rejoignez-nous",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 30),

                        _buildField(
                          controller: _lastNameController,
                          label: AppStrings.lastNameHint,
                          icon: Icons.person_outline,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Entrez votre nom';
                            }
                            if (v.trim().length < 2) {
                              return 'Minimum 2 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _firstNameController,
                          label: AppStrings.firstNameHint,
                          icon: Icons.badge_outlined,
                          textCapitalization: TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Entrez votre prénom';
                            }
                            if (v.trim().length < 2) {
                              return 'Minimum 2 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _telephoneController,
                          label: 'Numéro WhatsApp',
                          icon: Icons.chat_bubble_outline,
                          keyboardType: TextInputType.phone,
                          validator: Validators.telephoneBurkina,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _passwordController,
                          label: AppStrings.passwordHint,
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Entrez un mot de passe';
                            }
                            if (v.length < 6) return 'Minimum 6 caractères';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _confirmController,
                          label: AppStrings.confirmPasswordHint,
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Confirmez votre mot de passe';
                            }
                            if (v != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTermsRow(),
                        const SizedBox(height: 24),
                        _buildSignUpButton(),
                        const SizedBox(height: 30),
                        _buildDivider(),
                        const SizedBox(height: 20),
                        _buildSocialRow(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
          Text(
            AppStrings.alreadyAccount,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          TextButton(
            onPressed: _onSignIn,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppStrings.signIn,
              style: const TextStyle(
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure ?? false,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
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

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            activeColor: AppColors.accentText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.textMuted, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              children: [
                TextSpan(text: AppStrings.acceptTermsPrefix),
                TextSpan(
                  text: AppStrings.termsAndConditions,
                  style: TextStyle(
                    color: AppColors.accentText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GradientButton(label: AppStrings.signUpButton, onPressed: _onSignUp);
  }

  // ───────────── Réseaux sociaux ─────────────

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.orSignUpWith,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(AppAssets.appleIconUrl, Icons.apple, 'Apple'),
        const SizedBox(width: 20),
        _socialButton(AppAssets.facebookIconUrl, Icons.facebook, 'Facebook'),
        const SizedBox(width: 20),
        _socialButton(AppAssets.googleIconUrl, Icons.g_mobiledata, 'Google'),
      ],
    );
  }

  Widget _socialButton(String url, IconData fallback, String provider) {
    return Material(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      child: InkWell(
        onTap: () => _onSocialTap(provider),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 60,
          height: 60,
          child: Center(
            child: Image.network(
              url,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const SizedBox(width: 28, height: 28),
              errorBuilder: (context, error, stack) =>
                  Icon(fallback, size: 28, color: AppColors.textDark),
            ),
          ),
        ),
      ),
    );
  }
}
