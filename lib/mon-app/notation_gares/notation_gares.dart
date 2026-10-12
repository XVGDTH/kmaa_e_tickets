import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Un critère noté par un simple choix (bouton radio), pas une étoile —
/// plus parlant pour quelqu'un qui n'a pas l'habitude de noter.
class CritereGare {
  const CritereGare({
    required this.id,
    required this.label,
    required this.options,
  });
  final String id;
  final String label;
  final List<(String, int)> options; // (libellé, score 0 à 2)
}

const List<CritereGare> kCriteresGare = [
  CritereGare(
    id: 'ponctualite',
    label: 'Respect des horaires de départ',
    options: [
      ('Parti à l\'heure', 2),
      ('Léger retard (moins de 30 min)', 1),
      ('Retard important (plus de 30 min)', 0),
    ],
  ),
  CritereGare(
    id: 'proprete',
    label: 'Propreté de la gare',
    options: [('Propre', 2), ('Moyennement propre', 1), ('Sale', 0)],
  ),
  CritereGare(
    id: 'bruit',
    label: 'Calme / bruit à la gare',
    options: [('Calme', 2), ('Un peu bruyant', 1), ('Très bruyant', 0)],
  ),
  CritereGare(
    id: 'arrets',
    label: 'Arrêts imprévus pendant le trajet',
    options: [
      ('Aucun arrêt imprévu', 2),
      ('Un ou deux arrêts', 1),
      ('Plusieurs arrêts prolongés', 0),
    ],
  ),
  CritereGare(
    id: 'tracasseries',
    label: 'Tracasseries (fouilles, attentes administratives...)',
    options: [('Aucune', 2), ('Quelques-unes', 1), ('Nombreuses', 0)],
  ),
  CritereGare(
    id: 'courtoisie',
    label: 'Courtoisie du personnel',
    options: [('Très courtois', 2), ('Correct', 1), ('Peu courtois', 0)],
  ),
];

class AvisGare {
  const AvisGare({
    required this.id,
    required this.compagnieId,
    required this.gareQuartier,
    required this.billetReference,
    required this.date,
    required this.scores,
    this.commentaire = '',
  });

  final String id;
  final String compagnieId;
  final String gareQuartier;
  final String billetReference;
  final DateTime date;
  final Map<String, int> scores; // critereId -> score
  final String commentaire;

  double get noteSur5 {
    if (scores.isEmpty) return 0;
    final total = scores.values.fold(0, (a, b) => a + b);
    return (total / (scores.length * 2)) * 5;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'compagnieId': compagnieId,
    'gareQuartier': gareQuartier,
    'billetReference': billetReference,
    'date': date,
    'scores': scores,
    'commentaire': commentaire,
  };

  static AvisGare fromMap(Map<String, dynamic> m) => AvisGare(
    id: m['id'] as String,
    compagnieId: m['compagnieId'] as String,
    gareQuartier: m['gareQuartier'] as String,
    billetReference: m['billetReference'] as String,
    date: m['date'] as DateTime,
    scores: Map<String, int>.from(m['scores'] as Map),
    commentaire: m['commentaire'] as String? ?? '',
  );
}

class AvisGareStore {
  AvisGareStore._();
  static final AvisGareStore instance = AvisGareStore._();

  static const _boxName = 'avis_gares';
  late Box<Map> _box;

  final ValueNotifier<List<AvisGare>> avis = ValueNotifier<List<AvisGare>>([]);

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
    _reload();
  }

  void _reload() {
    avis.value = _box.values
        .map((m) => AvisGare.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> add(AvisGare a) async {
    await _box.put(a.id, a.toMap());
    _reload();
  }

  bool dejaNote(String billetReference) =>
      avis.value.any((a) => a.billetReference == billetReference);

  /// Moyenne et nombre d'avis pour une gare précise (toutes compagnies
  /// confondues sous le même nom de quartier, utile pour les escales
  /// partagées entre compagnies).
  (double, int) moyennePour(String compagnieId, String gareQuartier) {
    final pertinents = avis.value
        .where(
          (a) => a.compagnieId == compagnieId && a.gareQuartier == gareQuartier,
        )
        .toList();
    if (pertinents.isEmpty) return (0, 0);
    final moyenne =
        pertinents.map((a) => a.noteSur5).reduce((a, b) => a + b) /
        pertinents.length;
    return (moyenne, pertinents.length);
  }
}
