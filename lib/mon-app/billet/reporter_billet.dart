import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/dates.dart';
import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/service-rappel.dart';

class ReporterBilletScreen extends StatefulWidget {
  const ReporterBilletScreen({super.key, required this.billet});

  final Billet billet;

  @override
  State<ReporterBilletScreen> createState() => _ReporterBilletScreenState();
}

class _ReporterBilletScreenState extends State<ReporterBilletScreen> {
  static const _lettres = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _titre = TextStyle(
    color: AppColors.textDark,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  late final List<DateTime> _jours;
  int _jour = 0;
  List<Map<String, dynamic>> _creneaux = const [];
  String? _heure;
  bool _chargement = false;
  bool _envoi = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    final maintenant = DateTime.now();
    final debut = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final fin = widget.billet.dateValidite;
    // Jours possibles : d'aujourd'hui à la fin de validité du billet.
    final nb = fin.difference(debut).inDays.clamp(0, 30).toInt() + 1;
    _jours = List.generate(nb, (i) => debut.add(Duration(days: i)));
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
      _heure = null;
    });
    final jourDemande = _jour;
    try {
      final data = await ApiService.instance.creneauxDeReport(
        reference: widget.billet.reference,
        date: _jours[jourDemande],
      );
      if (!mounted || jourDemande != _jour) return;
      final liste = data['creneaux'];
      setState(() {
        _creneaux = liste is List
            ? liste
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()
            : const [];
        _chargement = false;
      });
    } on ApiException catch (e) {
      if (!mounted || jourDemande != _jour) return;
      setState(() {
        _creneaux = const [];
        _chargement = false;
        _erreur = e.message;
      });
    }
  }

  Future<void> _confirmer() async {
    final heure = _heure;
    if (heure == null || _envoi) return;

    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      await ApiService.instance.reporterBillet(
        reference: widget.billet.reference,
        date: _jours[_jour],
        heure: heure,
      );
      await TicketStore.instance.rafraichir();
      await AlertService.instance.replanifierTous();
      NotificationStore.instance.rafraichir();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre voyage a été reporté.')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _envoi = false;
        _erreur = e.statusCode == 409
            ? 'Il n\'y a plus assez de places sur ce départ.'
            : e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.billet;
    final pret = _heure != null && !_envoi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text(
          'Reporter mon voyage',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(
            '${b.depart} → ${b.arrivee}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Billet ${b.reference} · valable jusqu\'au ${formatDateFr(b.dateValidite)}',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 22),
          const Text('Choisissez un nouveau jour', style: _titre),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _jours.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _buildJour(i),
            ),
          ),
          const SizedBox(height: 22),
          const Text('Choisissez l\'heure du départ', style: _titre),
          const SizedBox(height: 10),
          _buildCreneaux(),
          if (_erreur != null) ...[
            const SizedBox(height: 14),
            Text(
              _erreur!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: pret ? AppColors.buttonGradient : null,
                color: pret ? null : AppColors.border,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: pret ? _confirmer : null,
                  child: Center(
                    child: _envoi
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Confirmer le report',
                            style: TextStyle(
                              color: pret
                                  ? AppColors.white
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJour(int i) {
    final date = _jours[i];
    final choisi = i == _jour;
    return GestureDetector(
      onTap: _envoi
          ? null
          : () {
              setState(() => _jour = i);
              _charger();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        decoration: BoxDecoration(
          gradient: choisi ? AppColors.buttonGradient : null,
          color: choisi ? null : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: choisi ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _lettres[date.weekday - 1],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: choisi ? AppColors.white : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: choisi ? AppColors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreneaux() {
    if (_chargement) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_creneaux.isEmpty) {
      return const Text(
        'Aucun départ ce jour-là. Choisissez un autre jour.',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [for (final c in _creneaux) _buildCreneau(c)],
    );
  }

  Widget _buildCreneau(Map<String, dynamic> c) {
    final heure = '${c['heure']}';
    final places = (c['places'] as num?)?.toInt() ?? 0;
    final passe = c['passe'] == true;
    final actuel = c['actuel'] == true;
    final complet = places < widget.billet.travelersCount;
    final actif = !passe && !actuel && !complet && !_envoi;
    final choisi = _heure == heure;

    final detail = actuel
        ? 'Votre départ actuel'
        : passe
        ? 'Parti'
        : complet
        ? 'Complet'
        : '$places place(s)';

    return GestureDetector(
      onTap: actif ? () => setState(() => _heure = heure) : null,
      child: Opacity(
        opacity: actif ? 1 : 0.45,
        child: Container(
          width: 104,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: choisi
                ? AppColors.secondary.withOpacity(0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: choisi ? AppColors.secondary : AppColors.border,
              width: choisi ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                heure,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
