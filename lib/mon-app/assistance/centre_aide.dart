import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/assistance/assistance_models.dart';
import 'package:kmaa_e_tickets/mon-app/assistance/fil_demande.dart';
import 'package:kmaa_e_tickets/mon-app/assistance/nouvelle_demande.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/service_client/service_client.dart';
import 'package:url_launcher/url_launcher.dart';

class CentreAideScreen extends StatefulWidget {
  const CentreAideScreen({super.key, this.billetReference});

  /// Billet depuis lequel l'aide est ouverte : il sera joint à la demande.
  final String? billetReference;

  @override
  State<CentreAideScreen> createState() => _CentreAideScreenState();
}

class _CentreAideScreenState extends State<CentreAideScreen> {
  List<FaqItem> _faq = [];
  Map<String, String> _themes = {};
  List<DemandeAssistance> _demandes = [];
  bool _chargement = true;
  String? _erreur;
  String _recherche = '';
  String _theme = 'tous';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  String _texteErreur(Object e) =>
      e is ApiException ? e.message : 'Impossible de joindre le serveur.';

  Future<void> _charger() async {
    try {
      final f = await ApiService.instance.assistanceFaq();
      final d = await ApiService.instance.mesDemandes();
      if (!mounted) return;
      setState(() {
        _faq = f.faq;
        _themes = f.themes;
        _demandes = d;
        _erreur = null;
        _chargement = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = _texteErreur(e);
        _chargement = false;
      });
    }
  }

  List<FaqItem> get _faqFiltree {
    final q = _recherche.trim().toLowerCase();
    return _faq.where((f) {
      final okTheme = _theme == 'tous' || f.theme == _theme;
      final okTexte =
          q.isEmpty ||
          f.question.toLowerCase().contains(q) ||
          f.reponse.toLowerCase().contains(q);
      return okTheme && okTexte;
    }).toList();
  }

  Future<void> _appeler() async {
    try {
      final ok = await launchUrl(
        Uri(scheme: 'tel', path: kServiceClientTelephone),
      );
      if (ok) return;
    } catch (_) {}
    _message(
      'Impossible d\'ouvrir le composeur. Composez le $kServiceClientAffichage.',
    );
  }

  Future<void> _whatsapp() async {
    final ref = widget.billetReference;
    final texte =
        'Bonjour, j\'ai besoin d\'aide${ref != null ? ' pour mon billet $ref' : ''}.';
    final uri = Uri.parse(
      'https://wa.me/$kWhatsappAssistance?text=${Uri.encodeComponent(texte)}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}
    _message('Impossible d\'ouvrir WhatsApp.');
  }

  void _message(String texte) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  Future<void> _ecrire() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NouvelleDemandeScreen(
          faq: _faq,
          themes: _themes,
          billetReference: widget.billetReference,
        ),
      ),
    );
    _charger();
  }

  Future<void> _ouvrir(DemandeAssistance d) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FilDemandeScreen(demandeId: d.id)),
    );
    _charger();
  }

  @override
  Widget build(BuildContext context) {
    final faq = _faqFiltree;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text(
          'Centre d\'aide',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ecrire,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Écrire au service client'),
      ),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            _hero(),
            const SizedBox(height: 16),
            Row(
              children: [
                _action(
                  Icons.call_rounded,
                  'Appeler',
                  kServiceClientAffichage,
                  _appeler,
                ),
                const SizedBox(width: 10),
                _action(Icons.chat_rounded, 'WhatsApp', 'Écrire', _whatsapp),
                const SizedBox(width: 10),
                _action(
                  Icons.mark_chat_unread_outlined,
                  'Message',
                  'Être rappelé',
                  _ecrire,
                ),
              ],
            ),
            if (_chargement)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_erreur != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _erreur!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            if (_demandes.isNotEmpty) ...[
              const SizedBox(height: 22),
              _titre('Mes demandes'),
              for (final d in _demandes) _tuileDemande(d),
            ],
            if (!_chargement && _erreur == null) ...[
              const SizedBox(height: 22),
              _titre('Questions fréquentes'),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chipTheme('tous', 'Toutes'),
                    for (final e in _themes.entries) _chipTheme(e.key, e.value),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (faq.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Aucune réponse ne correspond. Écrivez-nous : nous vous répondons.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              for (final f in faq) _carteFaq(f),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment pouvons-nous vous aider ?',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _recherche = v),
            decoration: InputDecoration(
              hintText: 'Rechercher une réponse…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (kServiceClientHoraires.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              kServiceClientHoraires,
              style: TextStyle(color: AppColors.white, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _action(
    IconData icone,
    String titre,
    String sous,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icone, color: AppColors.secondary, size: 26),
              const SizedBox(height: 6),
              Text(
                titre,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                sous,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titre(String texte) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      texte,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    ),
  );

  Widget _chipTheme(String cle, String libelle) {
    final actif = _theme == cle;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(libelle),
        selected: actif,
        onSelected: (_) => setState(() => _theme = cle),
        selectedColor: AppColors.secondary,
        labelStyle: TextStyle(
          color: actif ? AppColors.white : AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _carteFaq(FaqItem f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedAlignment: Alignment.centerLeft,
          title: Text(
            f.question,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          children: [
            Text(f.reponse, style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _tuileDemande(DemandeAssistance d) {
    final couleur = switch (d.statut) {
      'nouvelle' => const Color(0xFFF59E0B),
      'en_cours' => AppColors.secondary,
      _ => Colors.green,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _ouvrir(d),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: d.nonLus > 0 ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.objet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.themeLabel}${d.billetReference != null ? ' · ${d.billetReference}' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (d.nonLus > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${d.nonLus}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: couleur.withOpacity(.14),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                d.statutLabel,
                style: TextStyle(
                  color: couleur,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
