import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Identifiants des compagnies mises en favori, persistés localement.
class FavorisStore {
  FavorisStore._();
  static final FavorisStore instance = FavorisStore._();

  static const _boxName = 'favoris';
  late Box<bool> _box;

  final ValueNotifier<Set<String>> ids = ValueNotifier<Set<String>>({});

  Future<void> init() async {
    _box = await Hive.openBox<bool>(_boxName);
    ids.value = _box.keys.cast<String>().toSet();
  }

  bool isFavori(String compagnieId) => ids.value.contains(compagnieId);

  Future<void> toggle(String compagnieId) async {
    if (_box.containsKey(compagnieId)) {
      await _box.delete(compagnieId);
    } else {
      await _box.put(compagnieId, true);
    }
    ids.value = _box.keys.cast<String>().toSet();
  }
}
