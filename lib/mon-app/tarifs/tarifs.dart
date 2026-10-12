/// Utilitaires de formatage monétaire et taxe fixe de la billetterie.
class Tarif {
  Tarif._();

  /// Taxe unique prélevée par achat, quel que soit le nombre de tickets.
  static const int taxeFixe = 300;

  /// '10000' → '10 000 FCFA'
  static String format(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return '$buffer FCFA';
  }
}
