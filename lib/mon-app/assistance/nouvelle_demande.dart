import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/assistance/assistance_models.dart';
import 'package:kmaa_e_tickets/mon-app/assistance/fil_demande.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

class NouvelleDemandeScreen extends StatefulWidget {
  const NouvelleDemandeScreen({
    super.key,
    required this.faq,
    required this.themes,
    this.billetReference,
  });

  final List<FaqItem> faq;
  final Map<String, String> themes;
  final String? billetReference;

  @override
  State<NouvelleDemandeScreen> createState() => _NouvelleDemandeScreenState();
}

class _NouvelleDemandeScreenState extends State<NouvelleDemandeScreen> {
  final _objet = TextEditingController();
  final _message = TextEditingController();
  late String _theme;
  bool _rappel = false;
  bool _envoi = false;

  @override
  void initState() {
    super.initState();
    _theme = widget.billetReference != null
        ? 'billet'
        : (widget.themes.keys.isNotEmpty ? widget.themes.keys.first : 'autre');
  }

  @override
  void dispose() {
    _objet.dispose();
    _message.dispose();
    super.dispose();
  }

  /// Réponses de la FAQ qui ressemblent à ce que le client est en train d'écrire.
  List<FaqItem> get _suggestions {
    final mots = _objet.text
        .toLowerCase()
        .split(RegExp(r'[^a-zàâçéèêëîïôûùüÿ0-9]+'))
        .where((m) => m.length > 3)
        .toSet();
    if (mots.isEmpty) return const [];

    final notes = <FaqItem, int>{};
    for (final f in widget.faq) {
      final texte = '${f.question} ${f.reponse}'.toLowerCase();
      final score = mots.where(texte.contains).length;
      if (score > 0) notes[f] = score;
    }

    final tries = notes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return tries.take(3).map((e) => e.key).toList();
  }

  void _snack(String texte) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(texte)));

  Future<void> _envoyer() async {
    if (_envoi) return;

    final objet = _objet.text.trim();
    final message = _message.text.trim();

    if (objet.length < 3 || message.length < 5) {
      _snack('Indiquez un objet et décrivez votre demande.');
      return;
    }

    setState(() => _envoi = true);

    try {
      final d = await ApiService.instance.creerDemande(
        theme: _theme,
        objet: objet,
        message: message,
        billetReference: widget.billetReference,
        rappel: _rappel,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => FilDemandeScreen(demandeId: d.id)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _envoi = false);
      _snack(
        e is ApiException
            ? e.message
            : 'Envoi impossible. Vérifiez votre connexion.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text(
          'Nouvelle demande',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.billetReference != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Billet joint : ${widget.billetReference}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          const Text('Sujet', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final e in widget.themes.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: _theme == e.key,
                  onSelected: (_) => setState(() => _theme = e.key),
                  selectedColor: AppColors.secondary,
                  labelStyle: TextStyle(
                    color: _theme == e.key
                        ? AppColors.white
                        : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _objet,
            maxLength: 120,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Objet',
              hintText: 'Ex. : paiement débité sans billet',
              border: OutlineInputBorder(),
            ),
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Peut-être la réponse ?',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final f in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            f.reponse,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _message,
            maxLines: 6,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Votre message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _rappel,
            activeThumbColor: AppColors.secondary,
            onChanged: (v) => setState(() => _rappel = v),
            title: const Text(
              'Je souhaite être rappelé(e)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Un conseiller vous appellera sur le numéro de votre compte.',
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _envoi ? null : _envoyer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _envoi
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Envoyer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
