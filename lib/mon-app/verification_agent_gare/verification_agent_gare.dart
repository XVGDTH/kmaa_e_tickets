import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/dates.dart';
import 'package:kmaa_e_tickets/mon-app/widgets/loading_button.dart';

class VerifierBilletScreen extends StatefulWidget {
  const VerifierBilletScreen({super.key});

  @override
  State<VerifierBilletScreen> createState() => _VerifierBilletScreenState();
}

class _VerifierBilletScreenState extends State<VerifierBilletScreen> {
  final _refController = TextEditingController();
  final _nomController = TextEditingController();
  final _codeController = TextEditingController();

  Billet? _resultat;
  bool? _valide;

  void _verifier() {
    final billet = TicketStore.instance.billets.value
        .where(
          (b) =>
              b.reference.toUpperCase() ==
              _refController.text.trim().toUpperCase(),
        )
        .firstOrNull;

    setState(() {
      _resultat = billet;
      _valide =
          billet != null &&
          billet.verifierCode(
            _nomController.text.trim(),
            _codeController.text.trim(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text(
          'Vérifier un ticket',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildField(_refController, 'Référence du billet'),
          const SizedBox(height: 12),
          _buildField(_nomController, 'Nom du voyageur'),
          const SizedBox(height: 12),
          _buildField(_codeController, 'Code de vérification'),
          const SizedBox(height: 20),
          LoadingButton(
            label: 'Vérifier',
            loading: false,
            onPressed: _verifier,
          ),
          if (_valide != null) ...[
            const SizedBox(height: 24),
            _buildResultat(),
          ],
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildResultat() {
    final ok = _valide == true;
    final b = _resultat;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ok
            ? Colors.green.withOpacity(0.08)
            : AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ok ? Colors.green : AppColors.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ok ? Icons.check_circle : Icons.cancel,
                color: ok ? Colors.green : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                ok ? 'Ticket valide' : 'Ticket invalide',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: ok ? Colors.green : AppColors.error,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (ok && b != null) ...[
            const SizedBox(height: 10),
            Text(
              '${b.compagnie.name} — ${b.depart} → ${b.arrivee}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              'Départ : ${formatDateFr(b.dateVoyage)} à ${b.heure}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
