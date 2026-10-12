// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:kmaa_e_tickets/mon-app/accueil/accueil.dart';
// import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
// import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
// import 'package:kmaa_e_tickets/mon-app/gares_favorites/favorites.dart';
// import 'package:kmaa_e_tickets/mon-app/notation_gares/notation_gares.dart';
// import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';
// import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
// import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/service-rappel.dart';

// // appel et rappel telephonique avec voix feminine
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
//   await Hive.initFlutter();
//   await TicketStore.instance.init();
//   await UserStore.instance.init();
//   await NotificationStore.instance.init();
//   //initialisation des appels
//   await AlertService.instance.init(navigatorKey);
//   await AvisGareStore.instance.init();
//   await FavorisStore.instance.init();
//   runApp(const ConvergeApp());
// }

// class ConvergeApp extends StatelessWidget {
//   const ConvergeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Converge SAS',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         scaffoldBackgroundColor: AppColors.background,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: AppColors.primary,
//           primary: AppColors.primary,
//           onPrimary: AppColors.textDark,
//           secondary: AppColors.secondary,
//           onSecondary: AppColors.white,
//           error: AppColors.error,
//           surfaceTint: Colors.transparent,
//         ),
//         textSelectionTheme: TextSelectionThemeData(
//           cursorColor: AppColors.secondary,
//           selectionHandleColor: AppColors.secondary,
//           selectionColor: AppColors.primary.withOpacity(0.35),
//         ),
//       ),
//       home: const WelcomeScreen(),
//       routes: AppRoutes.routes,
//       onGenerateRoute: AppRoutes.onGenerateRoute,
//       // clé de navigation pour les appels et rappels
//       navigatorKey: navigatorKey,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kmaa_e_tickets/mon-app/accueil/accueil.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/gares_favorites/favorites.dart';
import 'package:kmaa_e_tickets/mon-app/home/home.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/notation_gares.dart';
import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/service-rappel.dart';
import 'package:kmaa_e_tickets/mon-app/widgets/loading_overlay.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late final Future<void> _appReady;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  _appReady = _initAll();
  runApp(const ConvergeApp());
}

Future<void> _initAll() async {
  await Hive.initFlutter();
  await TicketStore.instance.init();
  await UserStore.instance.init();
  await NotificationStore.instance.init();
  await FavorisStore.instance.init();
  await AvisGareStore.instance.init();
  await AlertService.instance.init(navigatorKey);
}

class ConvergeApp extends StatelessWidget {
  const ConvergeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converge SAS',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          onPrimary: AppColors.textDark,
          secondary: AppColors.secondary,
          onSecondary: AppColors.white,
          error: AppColors.error,
          surfaceTint: Colors.transparent,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.secondary,
          selectionHandleColor: AppColors.secondary,
          selectionColor: AppColors.primary.withOpacity(0.35),
        ),
      ),
      home: FutureBuilder<void>(
        future: _appReady,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingOverlay(message: 'Chargement...');
          }
          final p = UserStore.instance.profile.value;
          if (p != null && p.estAuthentifie) {
            return Home(lastName: p.nom, firstName: p.prenom);
          }
          return const WelcomeScreen();
        },
      ),
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
