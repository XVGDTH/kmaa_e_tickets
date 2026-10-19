import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';

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

/// Identité du client. Une fois estAuthentifie = true, l'appli ne
/// redemande plus jamais de connexion sur cet appareil — exactement le
/// principe Facebook / WhatsApp.
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

  // Future<void> deconnecter() async {
  //   final current = profile.value;
  //   if (current != null) await save(current.copyWith(estAuthentifie: false));
  // }
  /// Déconnexion volontaire : le serveur révoque le jeton de cet appareil.
  /// Au prochain lancement, l'application demandera de se reconnecter.
  Future<void> deconnecter() async {
    await ApiService.instance.deconnecter();
    final current = profile.value;
    if (current != null) await save(current.copyWith(estAuthentifie: false));
  }

  /// À appeler juste après une connexion réussie (login ou code OTP valide).
  /// Les noms viennent du serveur : le compte est retrouvé même sur un nouvel appareil.
  Future<UserProfile> ouvrirSession({required String telephone}) async {
    final serveur = ApiService.instance.utilisateur;
    final actuel = profile.value;

    UserProfile base;
    if (actuel != null && actuel.telephone == telephone) {
      base = actuel;
    } else {
      // Autre compte sur cet appareil : on repart de zéro, billets compris.
      await TicketStore.instance.vider();
      await NotificationStore.instance.vider();
      base = const UserProfile(prenom: '', nom: '');
    }

    final p = base.copyWith(
      prenom: '${serveur?['prenom'] ?? base.prenom}',
      nom: '${serveur?['nom'] ?? base.nom}',
      telephone: telephone,
      estAuthentifie: true,
    );
    await save(p);
    return p;
  }
}
