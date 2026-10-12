import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/notation_gares.dart';
import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';
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
  final Set<String> _avisNotifies = {};

  Timer? _ticker;
  final Map<String, DateTime> _dernierAppel = {};
  final Set<String> _silencePourAujourdhui = {};
  bool _callScreenOuvert = false;

  /// Banni au-dessus de l'accueil pour le rappel "jour lointain" — utile
  /// surtout sur le web, où les vraies notifications système ne marchent
  /// pas. Sur mobile, la vraie notification système prend le relais.
  final ValueNotifier<Billet?> rappelDuJour = ValueNotifier<Billet?>(null);

  Future<void> init(GlobalKey<NavigatorState> key) async {
    navigatorKey = key;

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

    if (!kIsWeb) {
      await _notifs.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      tzdata.initializeTimeZones();
    }

    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => _verifier());
    _verifierRappelJournalier();
  }

  bool _memeJour(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// À appeler juste après l'achat d'un billet.
  Future<void> planifierPour(Billet b) async {
    final now = DateTime.now();
    if (!_memeJour(b.dateVoyage, now)) {
      await _planifierNotificationsJournalieres(b);
    }
    _verifierRappelJournalier();
  }

  // ───────────── Jour J : appel vocal répété ─────────────

  void _verifier() {
    final now = DateTime.now();
    for (final b in TicketStore.instance.billets.value) {
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
          b.reference.hashCode + offset,
          'Rappel de voyage',
          'Votre trajet ${b.compagnie.name} (${b.depart} → ${b.arrivee}) est prévu le '
              '${jourVoyage.day}/${jourVoyage.month} à ${b.heure}. Pensez-y !',
          tz.TZDateTime.from(quand, tz.local),
          const NotificationDetails(
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
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
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
    final enAttente = <Billet>[];
    for (final b in TicketStore.instance.billets.value) {
      if (b.estAVenir || b.gare == null) continue;
      if (AvisGareStore.instance.dejaNote(b.reference)) continue;
      enAttente.add(b);
      if (_avisNotifies.add(b.reference)) {
        NotificationStore.instance.add(
          NotificationItem(
            id: 'avis-${b.reference}',
            type: NotifType.avis,
            title: "Comment s'est passé votre voyage ?",
            body:
                'Donnez votre avis sur la gare ${b.gare!.quartier} (${b.compagnie.name}).',
            date: DateTime.now(),
            billetReference: b.reference,
          ),
        );
      }
    }
    avisADonner.value = enAttente;
  }
}
