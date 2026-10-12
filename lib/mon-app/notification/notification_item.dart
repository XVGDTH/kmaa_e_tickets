import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  /// Référence du billet concerné, s'il y en a un — permet plus tard
  /// d'ouvrir directement ce billet en tapant la notification.
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
}

class NotificationStore {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  static const _boxName = 'notifications';
  late Box<Map> _box;

  final ValueNotifier<List<NotificationItem>> items =
      ValueNotifier<List<NotificationItem>>([]);

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
    if (_box.isEmpty) {
      await add(
        NotificationItem(
          id: 'bienvenue',
          type: NotifType.info,
          title: 'Bienvenue sur votr application !',
          body:
              'Réservez vos trajets en toute simplicité, où que vous soyez au Burkina.',
          date: DateTime.now(),
        ),
      );
    }
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

  Future<void> add(NotificationItem n) async {
    await _box.put(n.id, n.toMap());
    _reload();
  }

  Future<void> markRead(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final n = NotificationItem.fromMap(Map<String, dynamic>.from(raw));
    await _box.put(id, n.copyWith(read: true).toMap());
    _reload();
  }

  Future<void> markAllRead() async {
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final n = NotificationItem.fromMap(Map<String, dynamic>.from(raw));
      if (!n.read) await _box.put(key, n.copyWith(read: true).toMap());
    }
    _reload();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _reload();
  }

  int get unreadCount => items.value.where((n) => !n.read).length;
}
