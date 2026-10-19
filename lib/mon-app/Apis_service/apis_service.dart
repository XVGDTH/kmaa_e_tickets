import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Erreur du serveur ou du réseau, avec un message lisible par l'utilisateur.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.code, this.corps});

  final String message;
  final int? statusCode;

  /// Code métier éventuel du serveur (ex. 'telephone_non_verifie').
  final String? code;

  /// Corps JSON complet (ex. places_restantes, montant_attendu, taxe_attendue).
  final Map<String, dynamic>? corps;

  @override
  String toString() => message;
}

/// Point d'entrée UNIQUE pour tous les appels réseau de l'application.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String _urlEnv = String.fromEnvironment('API_URL');

  /// Adresse du backend. Sur un vrai téléphone :
  /// flutter run --dart-define=API_URL=http://192.168.1.20:8000/api
  static String get baseUrl {
    if (_urlEnv.isNotEmpty) return _urlEnv;
    if (kIsWeb) return 'http://localhost:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api'; // l'émulateur Android voit le PC ainsi
    }
    return 'http://localhost:8000/api';
  }

  static const String _cleToken = 'kmaa_token';
  static const Duration _delai = Duration(seconds: 20);
  final FlutterSecureStorage _stockage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _utilisateur;

  /// Dernier message d'erreur de login / vérification OTP (null si tout va bien).
  String? derniereErreur;
  String? derniereErreurCode;

  /// Appelé quand le serveur refuse le jeton (401) : retour à l'accueil.
  VoidCallback? onSessionExpiree;

  bool get estConnecte => _token != null;
  Map<String, dynamic>? get utilisateur => _utilisateur;

  /// Conservé pour compatibilité (n'enregistre pas le jeton sur le téléphone).
  void setToken(String? token) => _token = token;

  // ───────────── Session persistante (façon WhatsApp) ─────────────

  /// À appeler UNE fois au démarrage. Renvoie true si le client est déjà connecté.
  /// Sans réseau, la session est conservée (le client n'est jamais éjecté pour ça).
  Future<bool> restaurerSession() async {
    try {
      _token = await _stockage.read(key: _cleToken);
    } catch (_) {
      _token = null;
    }
    if (_token == null) return false;

    try {
      final data = await _appel(
        'GET',
        '/me',
        notifierExpiration: false,
        delai: const Duration(seconds: 6),
      );
      final user = data is Map<String, dynamic> ? data['user'] : null;
      _utilisateur = user is Map ? Map<String, dynamic>.from(user) : null;
      return true;
    } on ApiException catch (e) {
      return e.statusCode != 401; // 401 : session effacée par _appel
    }
  }

  /// Déconnexion volontaire : la prochaine ouverture demandera l'authentification.
  Future<void> deconnecter() async {
    if (_token != null) {
      try {
        await _appel('POST', '/auth/logout', notifierExpiration: false);
      } catch (_) {}
    }
    await _fermerSession();
  }

  Future<void> _ouvrirSession(Map<String, dynamic> data) async {
    _token = data['token'] as String?;
    final user = data['user'];
    _utilisateur = user is Map ? Map<String, dynamic>.from(user) : null;
    if (_token != null) {
      try {
        await _stockage.write(key: _cleToken, value: _token);
      } catch (_) {}
    }
  }

  Future<void> _fermerSession() async {
    _token = null;
    _utilisateur = null;
    try {
      await _stockage.delete(key: _cleToken);
    } catch (_) {}
  }

  // ───────────── Inscription / OTP WhatsApp / connexion ─────────────

  /// Crée le compte et déclenche l'envoi du code OTP par WhatsApp.
  /// Renvoie le corps du serveur ({'success': true/false, 'message', 'errors'}).
  Future<Map<String, dynamic>> register({
    required String prenom,
    required String nom,
    required String telephone,
    required String motDePasse,
  }) async {
    try {
      final data = await _appel(
        'POST',
        '/auth/register',
        auth: false,
        corps: {
          'prenom': prenom,
          'nom': nom,
          'telephone': telephone,
          'password': motDePasse,
        },
      );
      return data is Map<String, dynamic> ? data : {'success': true};
    } on ApiException catch (e) {
      if (e.statusCode != null && e.statusCode! < 500) {
        return {
          'success': false,
          'message': e.message,
          if (e.corps?['errors'] != null) 'errors': e.corps!['errors'],
        };
      }
      rethrow;
    }
  }

  /// Vérifie le code reçu. En cas de succès, le client est connecté ET la
  /// session est enregistrée sur le téléphone.
  Future<bool> verifierOtp({required String telephone, required String code}) =>
      _authentifier('/auth/verify-otp', {'telephone': telephone, 'code': code});

  Future<bool> login({required String telephone, required String motDePasse}) =>
      _authentifier('/auth/login', {
        'telephone': telephone,
        'password': motDePasse,
      });

  Future<void> renvoyerOtp(String telephone) async {
    await _appel(
      'POST',
      '/auth/resend-otp',
      auth: false,
      corps: {'telephone': telephone},
    );
  }

  /// Mot de passe oublié, étape 1 : un code est envoyé par WhatsApp (la réponse est
  /// identique que le numéro ait un compte ou non).
  Future<void> demanderReinitialisation(String telephone) async {
    await _appel(
      'POST',
      '/auth/forgot-password',
      auth: false,
      corps: {'telephone': telephone},
    );
  }

  /// Étape 2 : code reçu + nouveau mot de passe. En cas de succès, le client est connecté.
  Future<bool> reinitialiserMotDePasse({
    required String telephone,
    required String code,
    required String motDePasse,
  }) => _authentifier('/auth/reset-password', {
    'telephone': telephone,
    'code': code,
    'password': motDePasse,
  });

  Future<bool> _authentifier(String chemin, Map<String, dynamic> corps) async {
    derniereErreur = null;
    derniereErreurCode = null;
    try {
      final data = await _appel('POST', chemin, auth: false, corps: corps);
      if (data is Map<String, dynamic> && data['token'] is String) {
        await _ouvrirSession(data);
        return true;
      }
      derniereErreur = 'Réponse inattendue du serveur.';
      return false;
    } on ApiException catch (e) {
      derniereErreur = e.message;
      derniereErreurCode = e.code;
      if (e.statusCode != null && e.statusCode! < 500) return false;
      rethrow;
    }
  }

  // ───────────── Profil et avis ─────────────

  /// Met à jour le prénom et le nom du compte (le téléphone ne change pas ici).
  Future<void> modifierProfil({
    required String prenom,
    required String nom,
  }) async {
    final data = await _appel(
      'POST',
      '/me/profil',
      corps: {'prenom': prenom, 'nom': nom},
    );
    final user = data is Map<String, dynamic> ? data['user'] : null;
    if (user is Map) _utilisateur = Map<String, dynamic>.from(user);
  }

  /// Envoie l'avis d'un client sur la gare d'un de ses billets.
  Future<void> envoyerAvis({
    required String billetReference,
    required Map<String, int> scores,
    String commentaire = '',
  }) async {
    await _appel(
      'POST',
      '/avis-gares',
      corps: {
        'billet_reference': billetReference,
        'scores': scores,
        'commentaire': commentaire,
      },
    );
  }

  // ───────────── Transport ─────────────

  Future<List<Map<String, dynamic>>> fetchCompagnies() async {
    return _liste(await _appel('GET', '/compagnies'));
  }

  /// Villes de départ où cette compagnie a au moins une route active.
  /// [type] : 'national' ou 'international'.
  Future<List<String>> fetchVillesDepart(
    String compagnieSlug, {
    String type = 'national',
  }) async {
    final data = await _appel(
      'GET',
      '/compagnies/${Uri.encodeComponent(compagnieSlug)}/villes-depart',
      query: {'type': type},
    );
    return data is List ? data.map((e) => '$e').toList() : <String>[];
  }

  /// Destinations, gares, horaires et prix d'une compagnie au départ d'une ville.
  /// Avec [date], le serveur ne renvoie que les horaires de ce jour et les places
  /// restantes (champ 'disponibilites').
  Future<List<Map<String, dynamic>>> fetchRoutes({
    required String compagnieSlug,
    required String depart,
    DateTime? date,
    String type = 'national',
  }) async {
    final data = await _appel(
      'GET',
      '/compagnies/${Uri.encodeComponent(compagnieSlug)}/routes',
      query: {
        'depart': depart,
        'type': type,
        if (date != null) 'date': _jour(date),
      },
    );
    return _liste(data);
  }

  // ───────────── Billets ─────────────

  /// Achète un billet. Le prix est recalculé par le serveur ; en cas de désaccord
  /// il répond 422 avec 'montant_attendu' / 'taxe_attendue', et 409 avec
  /// 'places_restantes' s'il n'y a plus assez de places (voir ApiException.corps).
  Future<Map<String, dynamic>> creerBillet({
    required int routeId,
    required DateTime date,
    required String heure, // « 08h30 » ou « 08:30 » : le serveur normalise
    required List<String> voyageurs,
    required String operateur,
    int? montantAttendu,
    int? taxeAttendue,
  }) async {
    final data = await _appel(
      'POST',
      '/billets',
      corps: {
        'route_transport_id': routeId,
        'date_voyage': _jour(date),
        'heure': heure,
        'travelers_count': voyageurs.length,
        'operateur_paiement': operateur,
        'voyageurs': voyageurs,
        'montant_transport': ?montantAttendu,
        'taxe': ?taxeAttendue,
      },
    );
    final billet = data is Map ? data['billet'] : null;
    if (billet is! Map) throw ApiException('Réponse inattendue du serveur.');
    return Map<String, dynamic>.from(billet);
  }

  Future<List<Map<String, dynamic>>> mesBillets() async {
    return _liste(await _appel('GET', '/billets'));
  }

  // nouvelles methodes
  /// Départs possibles, un jour donné, pour reporter un billet.
  /// Réponse : {'valide_jusqu_au': '2026-10-26', 'creneaux': [{heure, places, passe, actuel}]}
  Future<Map<String, dynamic>> creneauxDeReport({
    required String reference,
    required DateTime date,
  }) async {
    final data = await _appel(
      'GET',
      '/billets/${Uri.encodeComponent(reference)}/creneaux',
      query: {'date': _jour(date)},
    );
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// Reporte le voyage à un autre jour, dans la durée de validité du billet.
  Future<Map<String, dynamic>> reporterBillet({
    required String reference,
    required DateTime date,
    required String heure,
  }) async {
    final data = await _appel(
      'POST',
      '/billets/${Uri.encodeComponent(reference)}/reporter',
      corps: {'date_voyage': _jour(date), 'heure': heure},
    );
    final billet = data is Map ? data['billet'] : null;
    if (billet is! Map) throw ApiException('Réponse inattendue du serveur.');
    return Map<String, dynamic>.from(billet);
  }

  // ───────────── Notifications (conservées sur le serveur) ─────────────

  /// Notifications du compte, les plus récentes d'abord.
  Future<List<Map<String, dynamic>>> mesNotifications() async {
    return _liste(await _appel('GET', '/notifications'));
  }

  Future<void> marquerNotificationLue(int id) async {
    await _appel('POST', '/notifications/$id/lue');
  }

  Future<void> toutMarquerLu() async {
    await _appel('POST', '/notifications/lire-tout');
  }

  /// Supprime la notification de l'application ; le serveur la conserve en base.
  Future<void> supprimerNotification(int id) async {
    await _appel('DELETE', '/notifications/$id');
  }

  // ───────────── Outils internes ─────────────

  Future<dynamic> _appel(
    String methode,
    String chemin, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? corps,
    bool auth = true,
    bool notifierExpiration = true,
    Duration? delai,
  }) async {
    var uri = Uri.parse('$baseUrl$chemin');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(
        queryParameters: query.map((k, v) => MapEntry(k, '$v')),
      );
    }

    final entetes = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (auth && _token != null) 'Authorization': 'Bearer $_token',
    };

    http.Response res;
    try {
      final requete = switch (methode) {
        'GET' => http.get(uri, headers: entetes),
        'DELETE' => http.delete(uri, headers: entetes),
        _ => http.post(uri, headers: entetes, body: jsonEncode(corps ?? {})),
      };
      res = await requete.timeout(delai ?? _delai);
    } on TimeoutException {
      throw ApiException('Le serveur met trop de temps à répondre. Réessayez.');
    } catch (_) {
      throw ApiException(
        'Connexion impossible. Vérifiez votre accès à internet.',
      );
    }

    dynamic json;
    if (res.bodyBytes.isNotEmpty) {
      try {
        json = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {}
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return json;

    // Jeton refusé : la session n'est plus valable, retour à la connexion.
    if (res.statusCode == 401 && auth && _token != null) {
      await _fermerSession();
      if (notifierExpiration) onSessionExpiree?.call();
    }

    final map = json is Map<String, dynamic> ? json : null;
    throw ApiException(
      _messageErreur(map, res.statusCode),
      statusCode: res.statusCode,
      code: map?['code'] is String ? map!['code'] as String : null,
      corps: map,
    );
  }

  String _messageErreur(Map<String, dynamic>? corps, int statut) {
    final erreurs = corps?['errors'];
    if (erreurs is Map && erreurs.isNotEmpty) {
      final premier = erreurs.values.first;
      if (premier is List && premier.isNotEmpty) return '${premier.first}';
      if (premier != null) return '$premier';
    }
    final message = corps?['message'];
    if (message is String && message.isNotEmpty) return message;
    if (statut == 401) return 'Session expirée. Reconnectez-vous.';
    if (statut == 429) {
      return 'Trop de tentatives. Réessayez dans quelques instants.';
    }
    if (statut >= 500) {
      return 'Le serveur rencontre un problème. Réessayez plus tard.';
    }
    return 'Une erreur est survenue.';
  }

  List<Map<String, dynamic>> _liste(dynamic data) {
    if (data is! List) return <Map<String, dynamic>>[];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _jour(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
