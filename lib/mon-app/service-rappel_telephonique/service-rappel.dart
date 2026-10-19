import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/notation_gares.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/appel_entrant.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

const Duration kFenetreAvantDepart = Duration(hours: 1);
const Duration kFenetreApresDepart = Duration(minutes: 30);
const Duration kIntervalleAppel = Duration(minutes: 2);
const int kHeureRappelJournalier = 9; // 9h00, jours lointains

/// Service unique qui gère toutes les alertes de départ : appel vocal
/// répété le jour J, et rappel une fois par jour les jours précédents.
class AlertService {
  AlertService._();
  static final AlertService instance = AlertService._();

  final FlutterTts _tts = FlutterTts();
  final FlutterLocalNotificationsPlugin _notifs =
      FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? navigatorKey;
  final ValueNotifier<List<Billet>> avisADonner = ValueNotifier<List<Billet>>(
    [],
  );
  // final Set<String> _avisNotifies = {};

  Timer? _ticker;
  final Map<String, DateTime> _dernierAppel = {};
  final Set<String> _silencePourAujourdhui = {};
  bool _callScreenOuvert = false;
  DateTime? _derniereSync;

  /// Banni au-dessus de l'accueil pour le rappel "jour lointain" — utile
  /// surtout sur le web, où les vraies notifications système ne marchent
  /// pas. Sur mobile, la vraie notification système prend le relais.
  final ValueNotifier<Billet?> rappelDuJour = ValueNotifier<Billet?>(null);

  Future<void> init(GlobalKey<NavigatorState> key) async {
    navigatorKey = key;

    if (kIsWeb) {
      unawaited(
        _configurerTts()
            .timeout(const Duration(seconds: 5))
            .catchError((Object error, StackTrace stackTrace) {
              FlutterError.reportError(
                FlutterErrorDetails(
                  exception: error,
                  stack: stackTrace,
                  library: 'AlertService',
                  context: ErrorDescription(
                    'while configuring web speech synthesis',
                  ),
                ),
              );
            }),
      );
    } else {
      await _configurerTts();
    }

    if (!kIsWeb) {
      await _notifs.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      tzdata.initializeTimeZones();
    }

    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => _verifier());
    _verifierRappelJournalier();
  }

  Future<void> _configurerTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.15); // légèrement plus aigu : rendu plus féminin
    try {
      final voices = await _tts.getVoices as List?;
      final voixFr = voices?.cast<Map>().firstWhere(
        (v) =>
            (v['locale'] as String? ?? '').toLowerCase().contains('fr') &&
            (v['name'] as String? ?? '').toLowerCase().contains('fem'),
        orElse: () => {},
      );
      if (voixFr != null && voixFr.isNotEmpty) {
        await _tts.setVoice({
          'name': voixFr['name'],
          'locale': voixFr['locale'],
        });
      }
    } catch (_) {
      // Pas grave si aucune voix féminine explicite n'est trouvée : la
      // voix française par défaut du système est utilisée.
    }
  }

  bool _memeJour(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// À appeler juste après l'achat d'un billet.

  /// À appeler après l'achat ou le report d'un billet : (re)programme ses rappels.
  Future<void> planifierPour(Billet b) async {
    await _annulerRappelsDe(b.reference);
    if (b.statut == 'valide' && !_memeJour(b.dateVoyage, DateTime.now())) {
      await _planifierNotificationsJournalieres(b);
    }
    _verifierRappelJournalier();
  }

  /// Remet les rappels à jour pour les billets à venir (après une synchronisation ou un report).
  Future<void> replanifierTous() async {
    final aujourdhui = DateTime.now();
    final debut = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);

    for (final b in TicketStore.instance.billets.value) {
      if (b.dateVoyage.isBefore(debut)) continue;
      await planifierPour(b);
    }
  }

  /// Annule les rappels « jours lointains » déjà programmés pour ce billet :
  /// après un report, l'ancienne date ne doit plus sonner.
  Future<void> _annulerRappelsDe(String reference) async {
    if (kIsWeb) return;
    for (var i = 0; i < 120; i++) {
      await _notifs.cancel(id: reference.hashCode + i);
    }
  }

  // ───────────── Jour J : appel vocal répété ─────────────

  // void _verifier() {
  //   final now = DateTime.now();
  //   for (final b in TicketStore.instance.billets.value) {
  //     if (!_memeJour(b.dateVoyage, now)) continue;
  //     if (_silencePourAujourdhui.contains(b.reference)) continue;

  //     final depart = b.dateHeureVoyage;
  //     final debut = depart.subtract(kFenetreAvantDepart);
  //     final fin = depart.add(kFenetreApresDepart);
  //     if (now.isBefore(debut) || now.isAfter(fin)) continue;

  //     final dernier = _dernierAppel[b.reference];
  //     if (dernier == null || now.difference(dernier) >= kIntervalleAppel) {
  //       _dernierAppel[b.reference] = now;
  //       _declencherAppel(b);
  //     }
  //   }
  //   // affichage des avis
  //   _verifierAvis();
  // }
  void _verifier() {
    final now = DateTime.now();
    _synchroniserSiNecessaire(now);

    for (final b in TicketStore.instance.billets.value) {
      // Seuls les billets valides sonnent : ni annulé, ni remboursé, ni embarqué, ni impayé.
      if (b.statut != 'valide') continue;
      if (!_memeJour(b.dateVoyage, now)) continue;
      if (_silencePourAujourdhui.contains(b.reference)) continue;

      final depart = b.dateHeureVoyage;
      final debut = depart.subtract(kFenetreAvantDepart);
      final fin = depart.add(kFenetreApresDepart);
      if (now.isBefore(debut) || now.isAfter(fin)) continue;

      final dernier = _dernierAppel[b.reference];
      if (dernier == null || now.difference(dernier) >= kIntervalleAppel) {
        _dernierAppel[b.reference] = now;
        _declencherAppel(b);
      }
    }
    // affichage des avis
    _verifierAvis();
  }

  Future<void> _declencherAppel(Billet b) async {
    if (_callScreenOuvert) return; // un appel à la fois
    _callScreenOuvert = true;

    if (!kIsWeb) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        Vibration.vibrate(pattern: [0, 800, 400, 800, 400, 800]);
      }
    }

    final nav = navigatorKey?.currentState;
    if (nav == null) {
      _callScreenOuvert = false;
      return;
    }

    await nav.push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, _, _) => IncomingCallScreen(
          billet: b,
          onSpeak: _parler,
          onIgnorer: () {},
          onArrive: () => _silencePourAujourdhui.add(b.reference),
        ),
      ),
    );

    _callScreenOuvert = false;
  }

  Future<void> _parler() async {
    await _tts.stop();
    await _tts.speak(
      "Veuillez vous préparer pour vous rendre à la gare choisie, afin d'effectuer votre déplacement.",
    );
  }

  // ───────────── Jours lointains : un rappel par jour ─────────────

  Future<void> _planifierNotificationsJournalieres(Billet b) async {
    if (kIsWeb) return; // pas de notifications programmées sur le web

    final jourVoyage = DateTime(
      b.dateVoyage.year,
      b.dateVoyage.month,
      b.dateVoyage.day,
    );
    var jour = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).add(const Duration(days: 1));

    var offset = 0;
    while (jour.isBefore(jourVoyage)) {
      final quand = DateTime(
        jour.year,
        jour.month,
        jour.day,
        kHeureRappelJournalier,
      );
      if (quand.isAfter(DateTime.now())) {
        await _notifs.zonedSchedule(
          id: b.reference.hashCode + offset,
          title: 'Rappel de voyage',
          body:
              'Votre trajet ${b.compagnie.name} (${b.depart} → ${b.arrivee}) est prévu le '
              '${jourVoyage.day}/${jourVoyage.month} à ${b.heure}. Pensez-y !',
          scheduledDate: tz.TZDateTime.from(quand, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'rappels_voyage',
              'Rappels de voyage',
              importance: Importance.high,
              priority: Priority.high,
              vibrationPattern: null,
            ),
            iOS: DarwinNotificationDetails(presentSound: true),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      jour = jour.add(const Duration(days: 1));
      offset++;
    }
  }

  /// Vérifie, à l'ouverture de l'app (et sur le web en particulier), s'il
  /// y a un rappel "jour lointain" à afficher aujourd'hui sous forme de
  /// bandeau dans l'application.

  void _verifierRappelJournalier() {
    final now = DateTime.now();
    for (final b in TicketStore.instance.billets.value) {
      if (b.statut != 'valide') continue;
      if (_memeJour(b.dateVoyage, now)) {
        continue; // le jour J est géré par l'appel vocal
      }
      if (b.dateVoyage.isBefore(now)) continue;
      rappelDuJour.value = b;
      return;
    }
    rappelDuJour.value = null;
  }

  void effacerRappelDuJour() => rappelDuJour.value = null;

  // methode d'affichage des avis dans les notifs

  void _verifierAvis() {
    avisADonner.value = TicketStore.instance.billets.value
        .where(
          (b) =>
              b.peutEtreNote &&
              b.gare != null &&
              !b.aAvis &&
              !AvisGareStore.instance.dejaNote(b.reference),
        )
        .toList();
  }

  /// Autour d'un départ, on recharge les billets toutes les 3 minutes : un voyageur déjà
  /// embarqué ou qui a reporté son voyage ne doit plus recevoir d'appel.
  void _synchroniserSiNecessaire(DateTime now) {
    final proche = TicketStore.instance.billets.value.any(
      (b) =>
          b.statut == 'valide' &&
          _memeJour(b.dateVoyage, now) &&
          now.isAfter(b.dateHeureVoyage.subtract(const Duration(hours: 2))) &&
          now.isBefore(b.dateHeureVoyage.add(const Duration(hours: 1))),
    );
    if (!proche) return;
    if (_derniereSync != null &&
        now.difference(_derniereSync!) < const Duration(minutes: 3)) {
      return;
    }
    _derniereSync = now;
    TicketStore.instance.rafraichir();
  }
}
