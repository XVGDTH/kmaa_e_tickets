import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/operateur_paiement.dart';
import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

Map<String, dynamic>? _gareToMap(DepartGare? g) {
  if (g == null) return null;
  return {
    'quartier': g.quartier,
    'horaires': g.horaires,
    'prixTicket': g.prixTicket,
    'dureeMax': g.dureeMax,
    'telephone': g.telephone,
    'adresse': g.adresse,
    'latitude': g.latitude,
    'longitude': g.longitude,
  };
}

DepartGare? _gareFromMap(dynamic raw) {
  if (raw == null) return null;
  final m = Map<String, dynamic>.from(raw as Map);
  return DepartGare(
    quartier: m['quartier'] as String,
    horaires: List<String>.from(m['horaires'] as List),
    prixTicket: m['prixTicket'] as int,
    dureeMax: m['dureeMax'] as String? ?? '—',
    telephone: m['telephone'] as String? ?? '',
    adresse: m['adresse'] as String? ?? '',
    latitude: (m['latitude'] as num?)?.toDouble() ?? 0,
    longitude: (m['longitude'] as num?)?.toDouble() ?? 0,
  );
}

class Billet {
  Billet({
    required this.reference,
    required this.compagnie,
    required this.depart,
    required this.arrivee,
    required this.dateVoyage,
    required this.heure,
    required this.travelersCount,
    required this.montantTransport,
    required this.taxe,
    required this.operateur,
    required this.datePaiement,
    required this.voyageurs,
    this.gare,
    this.statut = 'valide',
    this.codes = const [],
    this.valideJusqua,
    this.aAvis = false,
  });

  final String reference;
  final Compagnie compagnie;
  final String depart;
  final String arrivee;
  final DateTime dateVoyage;
  final String heure;
  final int travelersCount;
  final int montantTransport;
  final int taxe;
  final OperateurPaiement operateur;
  final DateTime datePaiement;
  final DepartGare? gare;
  final List<String> voyageurs;

  /// Statut officiel du serveur : valide, utilise, annule, rembourse, en_attente_paiement.
  final String statut;

  /// Codes passagers fournis par le serveur (même ordre que [voyageurs]).
  final List<String> codes;
  //  codes pour l'avis gare et le change profil
  /// Dernier jour d'utilisation du billet, calculé par le serveur.
  final DateTime? valideJusqua;

  /// Vrai si le client a déjà donné son avis (depuis n'importe quel appareil).
  final bool aAvis;
  //
  /// Un billet valide peut être reporté tant que sa durée de validité n'est pas écoulée.
  bool get peutEtreReporte =>
      statut == 'valide' &&
      DateTime.now().isBefore(
        DateTime(
          dateValidite.year,
          dateValidite.month,
          dateValidite.day,
          23,
          59,
          59,
        ),
      );

  // DateTime get dateValidite => datePaiement.add(const Duration(days: 15));
  /// Dernier jour d'utilisation : 12 jours après l'achat, jamais avant le jour du voyage.
  DateTime get dateValidite {
    if (valideJusqua != null) return valideJusqua!;
    final jourPaiement = DateTime(
      datePaiement.year,
      datePaiement.month,
      datePaiement.day,
    );
    final fin = jourPaiement.add(const Duration(days: 12));
    return dateVoyage.isAfter(fin) ? dateVoyage : fin;
  }

  DateTime get dateHeureVoyage {
    final parts = heure.split('h');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(dateVoyage.year, dateVoyage.month, dateVoyage.day, h, m);
  }

  bool get estAVenir =>
      (statut == 'valide' || statut == 'en_attente_paiement') &&
      DateTime.now().isBefore(dateHeureVoyage);

  String get statutLabel {
    switch (statut) {
      case 'utilise':
        return 'Utilisé';
      case 'annule':
        return 'Annulé';
      case 'rembourse':
        return 'Remboursé';
      case 'en_attente_paiement':
        return 'En attente de paiement';
      default:
        return estAVenir ? 'À venir' : 'Terminé';
    }
  }

  /// Une gare ne se note qu'après le départ, et pas pour un billet annulé,
  /// remboursé ou jamais payé.
  bool get peutEtreNote =>
      (statut == 'valide' || statut == 'utilise') && !estAVenir;

  String get qrData => reference;

  /// Un code court et unique par voyageur. Ce sont les codes officiels du
  /// serveur ; le calcul local ne sert que pour les anciens billets
  /// enregistrés avant la synchronisation.
  List<String> get codesVoyageurs {
    if (codes.isNotEmpty && codes.length == voyageurs.length) return codes;
    return List.generate(voyageurs.length, (i) {
      final raw = '$reference|$i|${voyageurs[i]}|CONVERGE_SAS_V1';
      return sha256
          .convert(utf8.encode(raw))
          .toString()
          .substring(0, 8)
          .toUpperCase();
    });
  }

  bool verifierCode(String nomVoyageur, String code) {
    final index = voyageurs.indexOf(nomVoyageur);
    final liste = codesVoyageurs;
    if (index == -1 || index >= liste.length) return false;
    return liste[index] == code.trim().toUpperCase();
  }

  Map<String, dynamic> toMap() => {
    'reference': reference,
    'compagnieId': compagnie.id,
    'depart': depart,
    'arrivee': arrivee,
    'dateVoyage': dateVoyage,
    'heure': heure,
    'travelersCount': travelersCount,
    'montantTransport': montantTransport,
    'taxe': taxe,
    'operateurId': operateur.id,
    'datePaiement': datePaiement,
    'voyageurs': voyageurs,
    'gare': _gareToMap(gare),
    'statut': statut,
    'codes': codes,
    'valideJusqua': valideJusqua,
    'aAvis': aAvis,
  };

  static Billet fromMap(Map<String, dynamic> map) {
    final compagnie =
        compagnieById(map['compagnieId'] as String) ??
        Compagnie(
          id: map['compagnieId'] as String,
          name: map['compagnieId'] as String,
        );

    final operateur =
        operateurById(map['operateurId'] as String) ?? kOperateurs.first;

    return Billet(
      reference: map['reference'] as String,
      compagnie: compagnie,
      depart: map['depart'] as String,
      arrivee: map['arrivee'] as String,
      dateVoyage: map['dateVoyage'] as DateTime,
      heure: map['heure'] as String,
      travelersCount: map['travelersCount'] as int,
      montantTransport: map['montantTransport'] as int,
      taxe: map['taxe'] as int,
      operateur: operateur,
      datePaiement: map['datePaiement'] as DateTime,
      voyageurs: List<String>.from(map['voyageurs'] as List),
      gare: _gareFromMap(map['gare']),
      statut: map['statut'] as String? ?? 'valide',
      codes: List<String>.from(map['codes'] as List? ?? const []),
      // les logiques de validation du profil ainsi que de l"avisdes voyageurs
      valideJusqua: map['valideJusqua'] as DateTime?,
      aAvis: map['aAvis'] as bool? ?? false,
    );
  }

  /// Construit un billet à partir de la réponse du serveur (GET /billets, POST /billets).
  static Billet fromApi(Map<String, dynamic> j) {
    final slug = '${j['compagnie'] ?? ''}';
    final compagnie = compagnieById(slug) ?? Compagnie(id: slug, name: slug);

    final nomOperateur = '${j['operateur_paiement'] ?? ''}';
    final operateur = kOperateurs.firstWhere(
      (o) => o.name == nomOperateur,
      orElse: () => kOperateurs.first,
    );

    final voyageurs = (j['voyageurs'] as List? ?? const [])
        .whereType<Map>()
        .toList();

    final g = j['gare'];
    final DepartGare? gare = g is Map
        ? DepartGare(
            quartier: '${g['quartier'] ?? ''}',
            horaires: const [],
            prixTicket: (j['prix_ticket'] as num?)?.toInt() ?? 0,
            dureeMax: (j['duree_max'] as String?) ?? '—',
            telephone: '${g['telephone'] ?? ''}',
            adresse: '${g['adresse'] ?? ''}',
            latitude: double.tryParse('${g['latitude'] ?? ''}') ?? 0,
            longitude: double.tryParse('${g['longitude'] ?? ''}') ?? 0,
          )
        : null;

    final paiement = DateTime.tryParse(
      '${j['date_paiement'] ?? ''}',
    )?.toLocal();

    return Billet(
      reference: '${j['reference']}',
      compagnie: compagnie,
      depart: '${j['depart'] ?? ''}',
      arrivee: '${j['arrivee'] ?? ''}',
      dateVoyage: DateTime.parse('${j['date_voyage']}'),
      // le serveur envoie « 08:30 », l'application affiche « 08h30 »
      heure: '${j['heure']}'.replaceAll(':', 'h'),
      travelersCount: (j['travelers_count'] as num).toInt(),
      montantTransport: (j['montant_transport'] as num).toInt(),
      taxe: (j['taxe'] as num).toInt(),
      operateur: operateur,
      datePaiement: paiement ?? DateTime.now(),
      voyageurs: voyageurs.map((v) => '${v['nom']}').toList(),
      codes: voyageurs.map((v) => '${v['code']}').toList(),
      statut: '${j['statut'] ?? 'valide'}',
      gare: gare,
      // logique du profil user et des avis
      valideJusqua: DateTime.tryParse('${j['valide_jusqu_au'] ?? ''}'),
      aAvis: j['a_avis'] == true,
    );
  }
}

/// Stockage local persistant avec Hive. Le serveur reste la source de vérité :
/// [rafraichir] remplace le contenu local par les billets du compte.
class TicketStore {
  TicketStore._();
  static final TicketStore instance = TicketStore._();

  static const _boxName = 'billets_v2';
  late Box<Map> _box;

  final ValueNotifier<List<Billet>> billets = ValueNotifier<List<Billet>>([]);

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
    _reload();
  }

  void _reload() {
    final list =
        _box.values
            .map((m) => Billet.fromMap(Map<String, dynamic>.from(m)))
            .toList()
          ..sort((a, b) => b.datePaiement.compareTo(a.datePaiement));
    billets.value = list;
  }

  Future<void> add(Billet billet) async {
    await _box.put(billet.reference, billet.toMap());
    _reload();
  }

  /// Recharge les billets depuis le serveur (statuts à jour, autres appareils).
  /// Sans réseau ou session expirée, on garde les billets déjà enregistrés.
  Future<void> rafraichir() async {
    try {
      final data = await ApiService.instance.mesBillets();
      final liste = <Billet>[];
      for (final j in data) {
        try {
          liste.add(Billet.fromApi(j));
        } catch (_) {
          // billet illisible : ignoré plutôt que de bloquer toute la liste
        }
      }
      await _box.clear();
      for (final b in liste) {
        await _box.put(b.reference, b.toMap());
      }
      _reload();
    } on ApiException {
      // hors ligne : on garde l'existant
    }
  }

  /// À utiliser quand un autre compte se connecte sur l'appareil.
  Future<void> vider() async {
    await _box.clear();
    _reload();
  }
}
