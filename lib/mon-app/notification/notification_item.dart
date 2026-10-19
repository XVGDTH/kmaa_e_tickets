import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';

enum NotifType { achat, rappel, promo, info, avis }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.date,
    this.read = false,
    this.billetReference,
  });

  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime date;
  final bool read;

  /// Référence du billet concerné, s'il y en a un.
  final String? billetReference;

  NotificationItem copyWith({bool? read}) => NotificationItem(
    id: id,
    type: type,
    title: title,
    body: body,
    date: date,
    read: read ?? this.read,
    billetReference: billetReference,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'title': title,
    'body': body,
    'date': date,
    'read': read,
    'billetReference': billetReference,
  };

  static NotificationItem fromMap(Map<String, dynamic> m) => NotificationItem(
    id: m['id'] as String,
    type: NotifType.values.firstWhere(
      (t) => t.name == m['type'],
      orElse: () => NotifType.info,
    ),
    title: m['title'] as String,
    body: m['body'] as String,
    date: m['date'] as DateTime,
    read: m['read'] as bool? ?? false,
    billetReference: m['billetReference'] as String?,
  );

  /// Notification venue du serveur (annulation, remboursement, report... : type « info »).
  static NotificationItem fromApi(Map<String, dynamic> j) {
    const types = {
      'achat': NotifType.achat,
      'rappel': NotifType.rappel,
      'avis': NotifType.avis,
      'promo': NotifType.promo,
    };
    return NotificationItem(
      id: '${j['id']}',
      type: types['${j['type']}'] ?? NotifType.info,
      title: '${j['titre'] ?? ''}',
      body: '${j['corps'] ?? ''}',
      date:
          DateTime.tryParse('${j['date'] ?? ''}')?.toLocal() ?? DateTime.now(),
      read: j['lu'] == true,
      billetReference: j['billet_reference'] as String?,
    );
  }
}

/// Les notifications du compte vivent sur le serveur : le téléphone en garde une copie.
/// Un identifiant numérique désigne une notification du serveur.
class NotificationStore {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  static const _boxName = 'notifications';
  static const _boxEnAttente = 'notifications_en_attente';
  late Box<Map> _box;
  late Box<String> _enAttente;

  final ValueNotifier<List<NotificationItem>> items =
      ValueNotifier<List<NotificationItem>>([]);

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
    _enAttente = await Hive.openBox<String>(_boxEnAttente);
    _reload();
  }

  void _reload() {
    final list =
        _box.values
            .map((m) => NotificationItem.fromMap(Map<String, dynamic>.from(m)))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    items.value = list;
  }

  /// Notification locale (non enregistrée sur le serveur).
  Future<void> add(NotificationItem n) async {
    await _box.put(n.id, n.toMap());
    _reload();
  }

  /// Recharge les notifications du serveur. Sans réseau, on garde l'existant.
  Future<void> rafraichir() async {
    try {
      await _envoyerEnAttente();
      final data = await ApiService.instance.mesNotifications();

      // On remplace celles du serveur ; on retire aussi les anciennes notifications
      // d'achat et de rappel fabriquées sur le téléphone.
      for (final cle in _box.keys.toList()) {
        final id = '$cle';
        if (int.tryParse(id) != null ||
            id.startsWith('achat-') ||
            id.startsWith('rappel-') ||
            id == 'bienvenue') {
          await _box.delete(cle);
        }
      }
      for (final j in data) {
        try {
          final n = NotificationItem.fromApi(j);
          await _box.put(n.id, n.toMap());
        } catch (_) {
          // notification illisible : ignorée
        }
      }
      _reload();
    } on ApiException {
      // hors ligne ou session expirée : on garde l'existant
    }
  }

  Future<void> markRead(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final n = NotificationItem.fromMap(Map<String, dynamic>.from(raw));
    await _box.put(id, n.copyWith(read: true).toMap());
    _reload();

    final numero = int.tryParse(id);
    if (numero != null) await _synchroniser('lue:$numero');
  }

  Future<void> markAllRead() async {
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final n = NotificationItem.fromMap(Map<String, dynamic>.from(raw));
      if (!n.read) await _box.put(key, n.copyWith(read: true).toMap());
    }
    _reload();
    await _synchroniser('toutlu');
  }

  /// Supprimée de l'application ; le serveur la garde en base.
  Future<void> delete(String id) async {
    await _box.delete(id);
    _reload();

    final numero = int.tryParse(id);
    if (numero != null) await _synchroniser('supprimer:$numero');
  }

  /// À utiliser quand un autre compte se connecte sur l'appareil.
  Future<void> vider() async {
    await _box.clear();
    await _enAttente.clear();
    _reload();
  }

  int get unreadCount => items.value.where((n) => !n.read).length;

  // ───────────── Synchronisation avec le serveur ─────────────

  Future<void> _executer(String operation) async {
    final morceaux = operation.split(':');
    switch (morceaux.first) {
      case 'supprimer':
        await ApiService.instance.supprimerNotification(int.parse(morceaux[1]));
      case 'lue':
        await ApiService.instance.marquerNotificationLue(
          int.parse(morceaux[1]),
        );
      case 'toutlu':
        await ApiService.instance.toutMarquerLu();
    }
  }

  /// Envoie tout de suite ; si le réseau est coupé, l'opération est retenue pour plus tard.
  Future<void> _synchroniser(String operation) async {
    try {
      await _executer(operation);
    } on ApiException catch (e) {
      if (e.statusCode == null) await _enAttente.add(operation);
    }
  }

  Future<void> _envoyerEnAttente() async {
    for (final cle in _enAttente.keys.toList()) {
      final operation = _enAttente.get(cle);
      if (operation == null) continue;
      try {
        await _executer(operation);
      } on ApiException catch (e) {
        if (e.statusCode == null) rethrow; // réseau coupé : on réessaiera
        // 404 ou autre refus : l'opération n'a plus de sens, on l'abandonne
      }
      await _enAttente.delete(cle);
    }
  }
}
