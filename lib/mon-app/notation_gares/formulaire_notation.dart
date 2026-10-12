import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/notation_gares/notation_gares.dart';

class NotationGareScreen extends StatefulWidget {
  const NotationGareScreen({super.key, required this.billet});
  final Billet billet;

  @override
  State<NotationGareScreen> createState() => _NotationGareScreenState();
}

class _NotationGareScreenState extends State<NotationGareScreen> {
  final Map<String, int> _reponses = {};
  final _commentaireController = TextEditingController();

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  bool get _complet => _reponses.length == kCriteresGare.length;

  void _submit() {
    AvisGareStore.instance.add(
      AvisGare(
        id: 'avis-${widget.billet.reference}',
        compagnieId: widget.billet.compagnie.id,
        gareQuartier: widget.billet.gare?.quartier ?? '',
        billetReference: widget.billet.reference,
        date: DateTime.now(),
        scores: Map.from(_reponses),
        commentaire: _commentaireController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Merci pour votre avis !')));
  }

  @override
  Widget build(BuildContext context) {
    final gareNom = widget.billet.gare?.quartier ?? 'cette gare';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text(
          'Donner mon avis',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Text(
            'Comment s\'est passé votre voyage au départ de $gareNom ?',
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          for (final critere in kCriteresGare) _buildCritere(critere),
          const SizedBox(height: 8),
          const Text(
            'Un commentaire à ajouter ? (facultatif)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentaireController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Décrivez votre expérience...',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
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
                gradient: _complet ? AppColors.buttonGradient : null,
                color: _complet ? null : AppColors.border,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _complet ? _submit : null,
                  child: Center(
                    child: Text(
                      'Envoyer mon avis',
                      style: TextStyle(
                        color: _complet ? AppColors.white : AppColors.textMuted,
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

  Widget _buildCritere(CritereGare critere) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            critere.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          for (final (label, score) in critere.options)
            _buildOption(critere.id, label, score),
        ],
      ),
    );
  }

  Widget _buildOption(String critereId, String label, int score) {
    final selected = _reponses[critereId] == score;
    return InkWell(
      onTap: () => setState(() => _reponses[critereId] = score),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? AppColors.secondary : AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                color: selected ? AppColors.textDark : AppColors.textMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
