import 'package:kmaa_e_tickets/mon-app/data_compagnies/data_ctrof.dart';
import 'package:kmaa_e_tickets/mon-app/data_compagnies/data_elitis.dart';
import 'package:kmaa_e_tickets/mon-app/data_compagnies/data_rahimo.dart';
import 'package:kmaa_e_tickets/mon-app/data_compagnies/data_rakieta.dart';
import 'package:kmaa_e_tickets/mon-app/data_compagnies/data_saramaya.dart';
import 'package:kmaa_e_tickets/mon-app/data_compagnies/data_staf.dart';
import 'package:kmaa_e_tickets/mon-app/data_compagnies/data_tcv.dart';
import 'package:kmaa_e_tickets/mon-app/data_compagnies/data_tsr.dart';

/// Une gare précise proposant un trajet, avec ses propres horaires et

class DepartGare {
  const DepartGare({
    required this.quartier,
    required this.horaires,
    required this.prixTicket,
    this.dureeMax = '—',
    this.telephone = '',
    this.adresse = '',
    this.latitude = 0,
    this.longitude = 0,
    this.routeId,
    this.gareId,
    this.disponibilites = const {},
  });

  final String quartier;
  final List<String> horaires;
  final int prixTicket;
  final String dureeMax;
  final String telephone;
  final String adresse;
  final double latitude;
  final double longitude;

  /// Identifiants côté serveur (null pour les données locales).
  final int? routeId;
  final int? gareId;

  /// Places restantes par horaire (« 08h30 » → 12), pour la date demandée.
  final Map<String, int> disponibilites;

  factory DepartGare.fromJson(Map<String, dynamic> j) {
    final dispo = <String, int>{};
    final brut = j['disponibilites'];
    if (brut is Map) {
      brut.forEach((k, v) => dispo['$k'] = (v as num?)?.toInt() ?? 0);
    }
    final duree = j['dureeMax'];

    return DepartGare(
      quartier: '${j['quartier'] ?? ''}',
      horaires: (j['horaires'] as List? ?? const []).map((e) => '$e').toList(),
      prixTicket: (j['prixTicket'] as num?)?.toInt() ?? 0,
      dureeMax: duree is String && duree.isNotEmpty ? duree : '—',
      telephone: '${j['telephone'] ?? ''}',
      adresse: '${j['adresse'] ?? ''}',
      latitude: double.tryParse('${j['latitude'] ?? ''}') ?? 0,
      longitude: double.tryParse('${j['longitude'] ?? ''}') ?? 0,
      routeId: (j['route_id'] as num?)?.toInt(),
      gareId: (j['gare_id'] as num?)?.toInt(),
      disponibilites: dispo,
    );
  }
}

/// Une destination, avec une ou plusieurs gares qui la desservent.
/// Une destination, avec une ou plusieurs gares qui la desservent.
class RouteOption {
  const RouteOption({
    required this.destination,
    required this.gares,
    this.pays = '',
    this.etranger = false,
  });
  final String destination;
  final List<DepartGare> gares;
  final String pays;
  final bool etranger;

  factory RouteOption.fromJson(Map<String, dynamic> j) => RouteOption(
    destination: '${j['destination'] ?? ''}',
    pays: '${j['pays'] ?? ''}',
    etranger: j['etranger'] == true,
    gares: (j['gares'] as List? ?? const [])
        .whereType<Map>()
        .map((g) => DepartGare.fromJson(Map<String, dynamic>.from(g)))
        .toList(),
  );
}

class CompagnieReseau {
  const CompagnieReseau({
    required this.routesParVille,
    this.tarifsInternational = const {},
  });
  final Map<String, List<RouteOption>> routesParVille;
  final Map<String, int> tarifsInternational;
}

String _normalize(String s) {
  const from = 'àâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ';
  const to = 'aaaeeeeiioouuucAAAEEEEIIOOUUUC';
  final buffer = StringBuffer();
  for (final ch in s.trim().toLowerCase().split('')) {
    final i = from.indexOf(ch);
    buffer.write(i >= 0 ? to[i] : ch);
  }
  return buffer.toString();
}

/// Registre : une compagnie sans données réelles n'a simplement pas
/// d'entrée ici.
final Map<String, CompagnieReseau> _reseaux = {
  // 'staf': staf,
  'staf_gare': staf,
  'tsr': tsr,
  'elitis': elitis,
  'rahimo': rahimo,
  'saramaya': saramaya,
  'tcv': tcv,
  'rakieta': rakieta,
  'ctrof': ctrof,
};

List<RouteOption> routesDepuis(String compagnieId, String ville) =>
    _reseaux[compagnieId]?.routesParVille[_normalize(ville)] ?? const [];

int prixInternational(String compagnieId, String ville) {
  final prix = _reseaux[compagnieId]?.tarifsInternational[_normalize(ville)];
  return prix ?? prixTicketInternational;
}

const int prixTicketInternational = 25000;
const List<String> horairesInternationalDefaut = ['07h00', '13h00', '19h00'];

/// Noms d'affichage des villes de départ couvertes. Corrigé : chaque
/// clé a bien sa propre valeur séparée par une virgule.
const Map<String, String> _nomsVilles = {
  'ouagadougou': 'Ouagadougou',
  'bobo-dioulasso': 'Bobo-Dioulasso',
  'banfora': 'Banfora',
  "fada n'gourma": "Fada N'Gourma",
};

List<String> villesDepartDisponibles(String compagnieId) {
  final reseau = _reseaux[compagnieId];
  if (reseau == null) return const [];
  final villes =
      reseau.routesParVille.keys.map((key) => _nomsVilles[key] ?? key).toList()
        ..sort();
  return villes;
}

//Coordonnées des quartier pour les gares connues,

const Map<String, (double, double)> _coordsParMotCle = {
  'gounghin': (12.362, -1.514),
  'larlé': (12.377, -1.529),
  'larle': (12.377, -1.529),
  'wemtenga': (12.352, -1.496),
  'paglayiri': (12.335, -1.481),
  "patte d'oie": (12.335, -1.481),
  'saaba': (12.368, -1.442),
  'pissy': (12.352, -1.567),
  'zad': (12.383, -1.487),
  'tampouy': (12.402, -1.551),
  'dassasgho': (12.375, -1.480),
  'charles de gaulle': (12.368, -1.498),
  'kalgondin': (12.386, -1.490),
  'tanghin': (12.402, -1.540),
  'oscar yaar': (12.363, -1.512),
  "gare de l'est": (12.380, -1.470),
  "fada n'gourma": (12.061, 0.359),
  'tounouma': (11.175, -4.300),
  'zone résidentielle b': (11.180, -4.295),
  'zone residentielle b': (11.180, -4.295),
  'bobo': (11.178, -4.297),
  'banfora': (10.633, -4.767),
};

// Coordonnées d'une gare
(double, double)? coordsPour(DepartGare g) {
  if (g.latitude != 0 || g.longitude != 0) return (g.latitude, g.longitude);
  final nom = g.quartier.toLowerCase();
  for (final entry in _coordsParMotCle.entries) {
    if (nom.contains(entry.key)) return entry.value;
  }
  return null;
}
