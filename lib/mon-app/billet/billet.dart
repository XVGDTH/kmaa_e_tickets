import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  DateTime get dateValidite => datePaiement.add(const Duration(days: 15));

  DateTime get dateHeureVoyage {
    final parts = heure.split('h');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(dateVoyage.year, dateVoyage.month, dateVoyage.day, h, m);
  }

  bool get estAVenir => DateTime.now().isBefore(dateHeureVoyage);
  String get statutLabel => estAVenir ? 'À venir' : 'Terminé';

  String get qrData =>
      'CONVERGE-SAS|ref:$reference|compagnie:${compagnie.id}|depart:$depart|arrivee:$arrivee|'
      'montant:$montantTransport|voyageurs:${voyageurs.join(",")}|emis:${datePaiement.toIso8601String()}';

  /// Un code court et unique par voyageur, vérifiable sans connexion
  /// réseau. Limite connue : la clé est dans l'appli, donc à terme ce
  /// calcul devra être fait et vérifié côté serveur pour une sécurité
  /// réellement infalsifiable.
  List<String> get codesVoyageurs => List.generate(voyageurs.length, (i) {
    final raw = '$reference|$i|${voyageurs[i]}|CONVERGE_SAS_V1';
    return sha256
        .convert(utf8.encode(raw))
        .toString()
        .substring(0, 8)
        .toUpperCase();
  });

  bool verifierCode(String nomVoyageur, String code) {
    final index = voyageurs.indexOf(nomVoyageur);
    if (index == -1) return false;
    return codesVoyageurs[index] == code.trim().toUpperCase();
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
    );
  }
}

/// Stockage local persistant avec Hive.
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
}
