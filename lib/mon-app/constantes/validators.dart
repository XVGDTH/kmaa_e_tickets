/// Règles de validation réutilisées partout dans l'appli — un seul
/// endroit à modifier si une règle change (longueur de téléphone,
/// format d'email, etc.).
class Validators {
  Validators._();

  static String? nom(String? value, {String champ = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) return '$champ est requis';
    if (value.trim().length < 2) return 'Minimum 2 caractères';
    return null;
  }

  static String? telephoneBurkina(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return 'Numéro à 8 chiffres requis';
    return null;
  }

  static String? email(String? value, {bool requis = false}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return requis ? 'Email requis' : null;
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(v)) return 'Email invalide';
    return null;
  }

  static String? motDePasse(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < minLength) return 'Minimum $minLength caractères';
    return null;
  }

  static String? confirmationMotDePasse(
    String? value,
    String motDePasseOriginal,
  ) {
    if (value == null || value.isEmpty) return 'Confirmez votre mot de passe';
    if (value != motDePasseOriginal) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  static String? age(String? value, {required int min, required int max}) {
    final a = int.tryParse(value ?? '');
    if (a == null) return 'Âge requis';
    if (a < min || a > max) return 'Entre $min et $max ans';
    return null;
  }

  static String? numeroCarte(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 12 || digits.length > 19) return 'Numéro invalide';
    return null;
  }

  static String? expirationCarte(String? value) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value ?? '')) return 'Format MM/AA';
    return null;
  }

  static String? cvv(String? value) {
    if (!RegExp(r'^\d{3,4}$').hasMatch(value ?? '')) return '3-4 chiffres';
    return null;
  }

  static String? requis(String? value, {String champ = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) return '$champ est requis';
    return null;
  }
}
