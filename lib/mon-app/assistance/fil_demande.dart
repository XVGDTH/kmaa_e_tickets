import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/assistance/assistance_models.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

class FilDemandeScreen extends StatefulWidget {
  const FilDemandeScreen({super.key, required this.demandeId});

  final int demandeId;

  @override
  State<FilDemandeScreen> createState() => _FilDemandeScreenState();
}

class _FilDemandeScreenState extends State<FilDemandeScreen> {
  DemandeAssistance? _d;
  String? _erreur;
  Timer? _timer;
  final _saisie = TextEditingController();
  final _scroll = ScrollController();
  bool _envoi = false;

  @override
  void initState() {
    super.initState();
    _charger();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _charger());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saisie.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final d = await ApiService.instance.detailDemande(widget.demandeId);
      if (!mounted) return;
      final change = _d == null || d.messages.length != _d!.messages.length;
      setState(() {
        _d = d;
        _erreur = null;
      });
      if (change) _descendre();
    } catch (e) {
      if (!mounted || _d != null) return;
      setState(
        () => _erreur = e is ApiException
            ? e.message
            : 'Impossible de joindre le serveur.',
      );
    }
  }

  void _descendre() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _snack(String texte) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(texte)));

  Future<void> _envoyer() async {
    final texte = _saisie.text.trim();
    if (texte.length < 2 || _envoi) return;

    setState(() => _envoi = true);
    try {
      final d = await ApiService.instance.repondreDemande(
        widget.demandeId,
        texte,
      );
      if (!mounted) return;
      _saisie.clear();
      setState(() {
        _d = d;
        _envoi = false;
      });
      _descendre();
    } catch (e) {
      if (!mounted) return;
      setState(() => _envoi = false);
      _snack(e is ApiException ? e.message : 'Envoi impossible.');
    }
  }

  Future<void> _noter(int note) async {
    try {
      await ApiService.instance.noterDemande(widget.demandeId, note);
      _snack('Merci pour votre avis !');
      _charger();
    } catch (e) {
      _snack(e is ApiException ? e.message : 'Envoi impossible.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _d;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: Text(
          d?.objet ?? 'Demande',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: d == null
          ? Center(
              child: _erreur != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_erreur!, textAlign: TextAlign.center),
                    )
                  : const CircularProgressIndicator(),
            )
          : Column(
              children: [
                if (d.rappel == 'demande')
                  _bandeau(
                    Icons.phone_in_talk_outlined,
                    'Un conseiller vous rappellera.',
                  ),
                if (d.rappel == 'fait')
                  _bandeau(
                    Icons.check_circle_outline,
                    'Le rappel a été effectué.',
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: d.messages.length,
                    itemBuilder: (_, i) => _bulle(d.messages[i]),
                  ),
                ),
                if (d.resolue && d.note == null) _carteNote(),
                if (d.resolue && d.note != null)
                  _bandeau(
                    Icons.star_rounded,
                    'Résolue · votre note : ${d.note}/5',
                  ),
                _barreSaisie(d.resolue),
              ],
            ),
    );
  }

  Widget _bandeau(IconData icone, String texte) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    color: const Color(0xFFE6F7F4),
    child: Row(
      children: [
        Icon(icone, size: 18, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texte,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Widget _bulle(MessageAssistance m) {
    // Le client est « moi » : ses messages à droite, ceux du service client à gauche.
    final moi = !m.duStaff;
    final h =
        '${m.date.day.toString().padLeft(2, '0')}/${m.date.month.toString().padLeft(2, '0')} '
        '${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: moi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .78,
        ),
        decoration: BoxDecoration(
          gradient: moi ? AppColors.buttonGradient : null,
          color: moi ? null : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(moi ? 18 : 4),
            bottomRight: Radius.circular(moi ? 4 : 18),
          ),
          border: moi ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!moi)
              const Text(
                'Service client',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            Text(
              m.corps,
              style: TextStyle(
                color: moi ? AppColors.white : AppColors.textDark,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              h,
              style: TextStyle(
                fontSize: 10.5,
                color: moi ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteNote() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        const Text(
          'Cette demande est résolue. Êtes-vous satisfait ?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                onPressed: () => _noter(i),
                icon: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF59E0B),
                  size: 30,
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _barreSaisie(bool resolue) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _saisie,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: resolue
                    ? 'Écrire pour rouvrir la demande…'
                    : 'Votre message…',
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.secondary,
            child: _envoi
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : IconButton(
                    onPressed: _envoyer,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
