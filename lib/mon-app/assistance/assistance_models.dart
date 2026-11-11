DateTime _date(dynamic v) =>
    DateTime.tryParse(v?.toString() ?? '')?.toLocal() ?? DateTime.now();

class FaqItem {
  const FaqItem({
    required this.theme,
    required this.question,
    required this.reponse,
  });

  final String theme;
  final String question;
  final String reponse;

  factory FaqItem.fromJson(Map<String, dynamic> j) => FaqItem(
    theme: j['theme']?.toString() ?? 'autre',
    question: j['q']?.toString() ?? '',
    reponse: j['r']?.toString() ?? '',
  );
}

class MessageAssistance {
  const MessageAssistance({
    required this.id,
    required this.duStaff,
    required this.corps,
    required this.date,
  });

  final int id;
  final bool duStaff;
  final String corps;
  final DateTime date;

  factory MessageAssistance.fromJson(Map<String, dynamic> j) =>
      MessageAssistance(
        id: (j['id'] as num?)?.toInt() ?? 0,
        duStaff: j['staff'] == true,
        corps: j['corps']?.toString() ?? '',
        date: _date(j['date']),
      );
}

class DemandeAssistance {
  const DemandeAssistance({
    required this.id,
    required this.theme,
    required this.themeLabel,
    required this.objet,
    required this.statut,
    required this.statutLabel,
    required this.billetReference,
    required this.rappel,
    required this.note,
    required this.nonLus,
    required this.derniereActivite,
    required this.messages,
  });

  final int id;
  final String theme;
  final String themeLabel;
  final String objet;
  final String statut; // nouvelle, en_cours, resolue
  final String statutLabel;
  final String? billetReference;
  final String? rappel;
  final int? note;
  final int nonLus;
  final DateTime derniereActivite;
  final List<MessageAssistance> messages;

  bool get resolue => statut == 'resolue';

  factory DemandeAssistance.fromJson(Map<String, dynamic> j) =>
      DemandeAssistance(
        id: (j['id'] as num?)?.toInt() ?? 0,
        theme: j['theme']?.toString() ?? 'autre',
        themeLabel: j['theme_label']?.toString() ?? '',
        objet: j['objet']?.toString() ?? '',
        statut: j['statut']?.toString() ?? 'nouvelle',
        statutLabel: j['statut_label']?.toString() ?? '',
        billetReference: j['billet_reference']?.toString(),
        rappel: j['rappel']?.toString(),
        note: (j['note'] as num?)?.toInt(),
        nonLus: (j['non_lus'] as num?)?.toInt() ?? 0,
        derniereActivite: _date(j['derniere_activite']),
        messages: ((j['messages'] as List?) ?? const [])
            .map(
              (e) => MessageAssistance.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
      );
}
