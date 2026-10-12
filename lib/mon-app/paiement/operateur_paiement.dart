import 'package:flutter/material.dart';

enum PaymentKind { mobileMoney, card }

/// Un moyen de paiement proposé à l'utilisateur.
class OperateurPaiement {
  const OperateurPaiement({
    required this.id,
    required this.name,
    required this.logo,
    required this.kind,
    required this.accent,
  });

  final String id;
  final String name;

  /// Chemin d'un asset ('assets/images/operateurs/orange_money.png')
  /// ou une URL commençant par 'http'.
  final String logo;

  final PaymentKind kind;
  final Color accent;
}

const List<OperateurPaiement> kOperateurs = [
  OperateurPaiement(
    id: 'orange_money',
    name: 'Orange Money',
    logo: 'assets/images/operateurs/orange.png',
    kind: PaymentKind.mobileMoney,
    accent: Color(0xFFFF7900),
  ),
  OperateurPaiement(
    id: 'moov_money',
    name: 'Moov Money',
    logo: 'assets/images/operateurs/moov.png',
    kind: PaymentKind.mobileMoney,
    accent: Color(0xFF0066B3),
  ),
  OperateurPaiement(
    id: 'telecel_money',
    name: 'Telecel Money',
    logo: 'assets/images/operateurs/telecel.png',
    kind: PaymentKind.mobileMoney,
    accent: Color(0xFFE30613),
  ),
  OperateurPaiement(
    id: 'coris_money',
    name: 'Coris Money',
    logo: 'assets/images/operateurs/coris.png',
    kind: PaymentKind.mobileMoney,
    accent: Color(0xFF00A651),
  ),
  OperateurPaiement(
    id: 'carte_bancaire',
    name: 'Carte bancaire',
    logo: 'assets/images/operateurs/visa.png',
    kind: PaymentKind.card,
    accent: Color(0xFF1A1F71),
  ),
];

OperateurPaiement? operateurById(String id) {
  for (final o in kOperateurs) {
    if (o.id == id) return o;
  }
  return null;
}
