const List<String> kJoursCourts = [
  'Lun',
  'Mar',
  'Mer',
  'Jeu',
  'Ven',
  'Sam',
  'Dim',
];

String formatDateFr(DateTime d) =>
    '${kJoursCourts[d.weekday - 1]} ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String formatDateCourte(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

// String formatHeure(int h) => '${h.toString().padLeft(2, '0')}h00';
String formatHeure(String h) => h;
