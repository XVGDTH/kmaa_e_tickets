import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/billet/mes_billets.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/menu.dart';
import 'package:kmaa_e_tickets/mon-app/forgot_password/forgot-password.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie-detail.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';
import 'package:kmaa_e_tickets/mon-app/home/home.dart';
import 'package:kmaa_e_tickets/mon-app/login/login.dart';
import 'package:kmaa_e_tickets/mon-app/notification/ecran_notification.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/ecran_profile.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
import 'package:kmaa_e_tickets/mon-app/register/register.dart';

/// Centralise les noms de routes, la table de routage et la navigation
/// déclenchée par le widget Menu. Un seul endroit à modifier pour toute
/// nouvelle page.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String billets = '/billets';
  static const String notifications = '/notifications';
  static const String profil = '/profil';
  // nouveau forgot password
  static const String forgotPassword = '/forgot-password';

  /// À passer directement à MaterialApp.routes.
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const Login(),
    signup: (context) => const SignUpScreen(),
    // home: (context) {
    //   final args = _args(context);
    //   return Home(lastName: args['nom'] ?? '', firstName: args['prenom'] ?? '');
    // },
    home: (context) {
      final args = _args(context);
      final profil = UserStore.instance.profile.value;
      // Si l'écran précédent n'a pas transmis les noms, on prend ceux du profil enregistré.
      return Home(
        lastName: (args['nom'] ?? '').isNotEmpty
            ? args['nom']!
            : (profil?.nom ?? ''),
        firstName: (args['prenom'] ?? '').isNotEmpty
            ? args['prenom']!
            : (profil?.prenom ?? ''),
      );
    },
    // menu lateral des billets
    billets: (context) => const MesBillets(),

    // routes pour les favoris
    // routes pour les notifications
    notifications: (context) => const NotificationsScreen(),
    // route pour le profil
    profil: (context) => const ProfilScreen(),
    // routes pour le mot de passe oublié
    forgotPassword: (context) => const ForgotPasswordScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'compagnie') {
      final id = uri.pathSegments[1];
      final args = settings.arguments;

      Compagnie? compagnie;
      var nom = '';
      var prenom = '';

      if (args is Map) {
        compagnie = args['compagnie'] is Compagnie
            ? args['compagnie'] as Compagnie
            : null;
        nom = args['nom']?.toString() ?? '';
        prenom = args['prenom']?.toString() ?? '';
      } else if (args is Compagnie) {
        compagnie = args;
      }

      compagnie ??= compagnieById(id);
      if (compagnie == null) return null;

      return MaterialPageRoute(
        settings: settings,
        builder: (_) => CompagnieDetail(
          compagnie: compagnie!,
          lastName: nom,
          firstName: prenom,
        ),
      );
    }

    return null;
  }

  static Map<String, String> _args(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    }
    return const {};
  }

  /// Utilisée par le widget Menu sur chaque écran pour changer d'onglet.
  static void navigateFromMenu(
    BuildContext context,
    MenuItem item, {
    String nom = '',
    String prenom = '',
  }) {
    if (item == MenuItem.accueil &&
        ModalRoute.of(context)?.settings.name == home) {
      return; // déjà sur Accueil
    }
    final target = switch (item) {
      MenuItem.accueil => home,
      MenuItem.billets => billets,
      MenuItem.notifications => notifications,
      MenuItem.profil => profil,
    };
    Navigator.of(
      context,
    ).pushReplacementNamed(target, arguments: {'nom': nom, 'prenom': prenom});
  }
}
