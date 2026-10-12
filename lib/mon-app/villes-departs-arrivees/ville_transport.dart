/// Villes reconnues par l'application, avec leurs alias (abréviations,
/// variantes d'orthographe) pour l'autocomplétion — utile pour les
/// personnes qui ne liront pas ou n'écriront pas le nom complet.
const Map<String, List<String>> villeAliases = {
  'Ouagadougou': [
    'ouaga',
    'ouagadougou',
    'waga',
    'ouagas',
    'ouahigouy',
  ], // dernier retiré si conflit
  'Bobo-Dioulasso': ['bobo', 'bobo-dioulasso', 'bobodioulasso'],
  'Koudougou': ['koudougou', 'kdg'],
  'Ouahigouya': ['ouahigouya', 'ouahi'],
  'Kaya': ['kaya'],
  'Tenkodogo': ['tenkodogo', 'tenkodog'],
  "Fada N'Gourma": ['fada', 'fadangourma', "fada n'gourma"],
  'Gaoua': ['gaoua'],
  'Dédougou': ['dedougou', 'dédougou'],
  'Banfora': ['banfora'],
  'Dori': ['dori'],
  'Kongoussi': ['kongoussi'],
  'Manga': ['manga'],
  'Léo': ['leo', 'léo'],
  'Boromo': ['boromo'],
  'Diapaga': ['diapaga'],
  'Zabré': ['zabre', 'zabré'],
  'Diébougou': ['diebougou', 'diébougou'],
  'Gourcy': ['gourcy'],
  'Yako': ['yako'],
  'Boussé': ['bousse', 'boussé'],
  'Cinkansé': ['cinkanse', 'cinkansé', 'cinkance'],
  'Kampti': ['kampti'],
  'Bittou': ['bittou'],
  'Koupéla': ['koupela', 'koupéla'],
};

String normalizeVille(String s) {
  const from = 'àâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ';
  const to = 'aaaeeeeiioouuucAAAEEEEIIOOUUUC';
  final buffer = StringBuffer();
  for (final ch in s.trim().toLowerCase().split('')) {
    final i = from.indexOf(ch);
    buffer.write(i >= 0 ? to[i] : ch);
  }
  return buffer.toString();
}

/// Renvoie les villes dont un alias commence par [query] (dès 2 lettres),
/// pour l'autocomplétion. Insensible aux accents et à la casse.
List<String> suggestVilles(String query) {
  final q = normalizeVille(query);
  if (q.length < 2) return const [];
  final matches = <String>[];
  villeAliases.forEach((ville, aliases) {
    if (aliases.any((a) => normalizeVille(a).startsWith(q))) matches.add(ville);
  });
  return matches;
}
