class Compagnie {
  const Compagnie({
    required this.id,
    required this.name,
    this.image,
    this.tags = const ['Compagnie', 'Interurbain'],
    this.rating,
  });

  /// Identifiant unique et stable (ex. 'staf'), utilisé pour la navigation,
  /// les favoris et plus tard les clés de ton tableau de bord / API.
  final String id;

  final String name;

  /// Chemin de l'image dans les assets (ex. 'assets/images/compagnies/staf.png').
  /// Si null ou introuvable, une icône de bus est affichée.
  final String? image;

  /// Petites étiquettes en haut de la carte.
  final List<String> tags;

  /// Note (null = étoile masquée).
  final double? rating;
}

/// Ajoute simplement une ligne pour chaque nouvelle compagnie / gare.
/// Les notes et étiquettes sont des valeurs d'exemple à remplacer.
const List<Compagnie> kCompagnies = [
  Compagnie(
    // id: 'staf',
    id: 'staf_gare',
    name: 'STAF',
    image: 'assets/images/compagnies/staf.png',
    rating: 4.5,
  ),
  Compagnie(
    id: 'rahimo',
    name: 'Rahimo',
    image: 'assets/images/compagnies/rahimo.png',
    rating: 4.5,
  ),
  Compagnie(
    id: 'elitis',
    name: 'Elitis',
    image: 'assets/images/compagnies/elitis.png',
    rating: 4.5,
  ),
  Compagnie(
    id: 'tsr',
    name: 'TSR',
    image: 'assets/images/compagnies/tsr.png',
    rating: 4.5,
  ),
  Compagnie(
    id: 'tcv',
    name: 'TCV',
    image: 'assets/images/compagnies/tcv.png',
    rating: 4.5,
  ),
  Compagnie(
    id: 'rakieta',
    name: 'Rakieta',
    image: 'assets/images/compagnies/rakieta.png',
    rating: 4.5,
  ),
  Compagnie(
    id: 'saramaya',
    name: 'Saramaya',
    image: 'assets/images/compagnies/saramaya.png',
    rating: 4.5,
  ),
  Compagnie(
    id: 'ctrof',
    name: 'Ctrof',
    image: 'assets/images/compagnies/ctrof.png',
    rating: 4.5,
  ),
];

/// Recherche une compagnie par son identifiant — utile quand on arrive
/// directement sur une URL comme /compagnie/staf (rechargement de page).
Compagnie? compagnieById(String id) {
  for (final c in kCompagnies) {
    if (c.id == id) return c;
  }
  return null;
}
