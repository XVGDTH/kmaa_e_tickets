import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Point d'entrée UNIQUE pour tous les appels réseau de l'application.
/// Tant que le backend Laravel n'existe pas, kModeDemo simule les
/// réponses pour que l'appli reste testable. Dès que le backend est en
/// ligne, passe kModeDemo à false et remplis baseUrl — rien d'autre
/// n'a besoin de changer dans le reste de l'appli.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String baseUrl = 'http://localhost:8000/api';
  static const bool kModeDemo = true;

  String? _token;
  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ───────────── Inscription / OTP WhatsApp ─────────────

  /// Crée le compte côté serveur, qui déclenche l'envoi du code OTP par
  /// WhatsApp via l'API Meta Cloud (intégrée côté Laravel uniquement).
  Future<Map<String, dynamic>> register({
    required String prenom,
    required String nom,
    required String telephone,
    required String motDePasse,
  }) async {
    if (kModeDemo) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {'success': true, 'otpDemo': _genererOtpDemo(telephone)};
    }
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        'password': motDePasse,
      }),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<bool> verifierOtp({
    required String telephone,
    required String code,
  }) async {
    if (kModeDemo) {
      await Future.delayed(const Duration(milliseconds: 500));
      return code == _otpDemoActuel[telephone];
    }
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: _headers,
      body: jsonEncode({'telephone': telephone, 'code': code}),
    );
    if (res.statusCode != 200) return false;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _token = data['token'] as String?;
    return true;
  }

  Future<bool> login({
    required String telephone,
    required String motDePasse,
  }) async {
    if (kModeDemo) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'telephone': telephone, 'password': motDePasse}),
    );
    if (res.statusCode != 200) return false;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _token = data['token'] as String?;
    return true;
  }

  final Map<String, String> _otpDemoActuel = {};

  String _genererOtpDemo(String telephone) {
    final code = (100000 + Random().nextInt(900000)).toString();
    _otpDemoActuel[telephone] = code;
    return code;
  }

  // ───────────── Référentiel transport — pour la future migration ─────────────
  // Une fois le backend Laravel/Filament prêt : remplacer les fichiers
  // compagnies/*.dart par ces appels.
  // Future<List<dynamic>> fetchCompagnies() async { ... }
  // Future<List<dynamic>> fetchRoutes(String compagnieId, String ville) async { ... }
}
