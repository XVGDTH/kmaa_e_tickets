/// Utilitaires de formatage monétaire et taxe fixe de la billetterie.
class Tarif {
  Tarif._();

  /// Taxe unique prélevée par achat, quel que soit le nombre de tickets.
  static const int taxeFixe = 300;

  /// Frais de repli quand le serveur n'en envoie pas (anciennes données locales). Même grille que le serveur.
  static int fraisParDefaut(int prixBillet, {bool international = false}) {
    if (international) return 1000;
    if (prixBillet <= 1000) return 100;
    if (prixBillet <= 2500) return 150;
    if (prixBillet <= 3000) return 200;
    if (prixBillet <= 5999) return 250;
    return 300;
  }

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
