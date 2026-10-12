import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

String hasherMotDePasse(String motDePasse) =>
    sha256.convert(utf8.encode(motDePasse)).toString();

class UserProfile {
  const UserProfile({
    required this.prenom,
    required this.nom,
    this.telephone = '',
    this.email = '',
    this.motDePasseHash = '',
    this.estAuthentifie = false,
    this.recevoirRappels = true,
  });

  final String prenom;
  final String nom;
  final String telephone;
  final String email;
  final String motDePasseHash;
  final bool estAuthentifie;
  final bool recevoirRappels;

  String get nomComplet => '$prenom $nom'.trim();

  String get initiales {
    final a = prenom.isNotEmpty ? prenom[0] : '';
    final b = nom.isNotEmpty ? nom[0] : '';
    final r = '$a$b'.toUpperCase();
    return r.isEmpty ? '?' : r;
  }

  UserProfile copyWith({
    String? prenom,
    String? nom,
    String? telephone,
    String? email,
    String? motDePasseHash,
    bool? estAuthentifie,
    bool? recevoirRappels,
  }) {
    return UserProfile(
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      motDePasseHash: motDePasseHash ?? this.motDePasseHash,
      estAuthentifie: estAuthentifie ?? this.estAuthentifie,
      recevoirRappels: recevoirRappels ?? this.recevoirRappels,
    );
  }

  Map<String, dynamic> toMap() => {
    'prenom': prenom,
    'nom': nom,
    'telephone': telephone,
    'email': email,
    'motDePasseHash': motDePasseHash,
    'estAuthentifie': estAuthentifie,
    'recevoirRappels': recevoirRappels,
  };

  static UserProfile fromMap(Map<String, dynamic> m) => UserProfile(
    prenom: m['prenom'] as String? ?? '',
    nom: m['nom'] as String? ?? '',
    telephone: m['telephone'] as String? ?? '',
    email: m['email'] as String? ?? '',
    motDePasseHash: m['motDePasseHash'] as String? ?? '',
    estAuthentifie: m['estAuthentifie'] as bool? ?? false,
    recevoirRappels: m['recevoirRappels'] as bool? ?? true,
  );
}

/// Identité du client, persistée localement (Hive). Une fois
/// estAuthentifie = true, l'appli ne redemande plus jamais de connexion
/// sur cet appareil — exactement le principe Facebook / WhatsApp.
class UserStore {
  UserStore._();
  static final UserStore instance = UserStore._();

  static const _boxName = 'user_profile';
  late Box<Map> _box;

  final ValueNotifier<UserProfile?> profile = ValueNotifier<UserProfile?>(null);

  bool get estConnecte => profile.value?.estAuthentifie ?? false;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
    final raw = _box.get('current');
    if (raw != null) {
      profile.value = UserProfile.fromMap(Map<String, dynamic>.from(raw));
    }
  }

  Future<void> save(UserProfile p) async {
    await _box.put('current', p.toMap());
    profile.value = p;
  }

  Future<void> deconnecter() async {
    final current = profile.value;
    if (current != null) await save(current.copyWith(estAuthentifie: false));
  }
}
