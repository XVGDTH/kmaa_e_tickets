import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/home/compagnie.dart';
import 'package:kmaa_e_tickets/mon-app/logo-operateurs-telephoniques/logo-operateur-telephonique.dart';
import 'package:kmaa_e_tickets/mon-app/notification/notification_item.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/confirmation_paiement.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/consentement_paiement.dart';
import 'package:kmaa_e_tickets/mon-app/paiement/operateur_paiement.dart';
import 'package:kmaa_e_tickets/mon-app/service-rappel_telephonique/service-rappel.dart';
import 'package:kmaa_e_tickets/mon-app/tarifs/tarifs.dart';
import 'package:kmaa_e_tickets/mon-app/transport/reseau_transport.dart';

enum _Step { taxe, transport }

class ChoixOperateur extends StatefulWidget {
  const ChoixOperateur({
    super.key,
    required this.compagnie,
    required this.depart,
    required this.arrivee,
    required this.date,
    required this.hour,
    required this.travelersCount,
    required this.montantTransport,
    required this.taxe,
    required this.voyageurNames,
    required this.gare,
  });

  final Compagnie compagnie;
  final String depart;
  final String arrivee;
  final DateTime date;
  // final int hour;
  final String hour;
  final int travelersCount;
  final int montantTransport;
  final int taxe;
  final List<String> voyageurNames;
  final DepartGare? gare;

  @override
  State<ChoixOperateur> createState() => _ChoixOperateurState();
}

class _ChoixOperateurState extends State<ChoixOperateur> {
  final _formKey = GlobalKey<FormState>();

  OperateurPaiement? _selected;
  _Step _step = _Step.taxe;
  bool _processing = false;

  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  int get _montantTotal => widget.taxe + widget.montantTransport;

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  Future<void> _onPay() async {
    if (_selected == null) {
      _message('Choisissez un moyen de paiement.');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _processing = true);

    // Simulation du paiement (sera remplacée par LigdiCash).
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    if (_step == _Step.taxe) {
      setState(() {
        _processing = false;
        _step = _Step.transport;
      });
      _message('Taxe de ${Tarif.format(widget.taxe)} payée avec succès.');
      return;
    }

    // Étape finale : le serveur crée le billet (prix, taxe et places contrôlés par lui).
    final routeId = widget.gare?.routeId;
    if (routeId == null) {
      setState(() => _processing = false);
      _message('Ce trajet n\'est pas encore disponible à l\'achat en ligne.');
      return;
    }

    Map<String, dynamic> recu;
    try {
      recu = await ApiService.instance.creerBillet(
        routeId: routeId,
        date: widget.date,
        heure: widget.hour,
        voyageurs: widget.voyageurNames,
        operateur: _selected!.name,
        montantAttendu: widget.montantTransport,
        taxeAttendue: widget.taxe,
        consentement:
            true, // coché sur l'écran de récapitulatif, avant tout paiement
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      _message(_texteErreurAchat(e));
      return;
    }

    if (!mounted) return;
    setState(() => _processing = false);

    ///

    // Le billet vient du serveur : référence, statut et codes passagers officiels.
    final billetCree = Billet.fromApi(recu);
    final reference = billetCree.reference;
    await TicketStore.instance.add(billetCree);
    NotificationStore.instance
        .rafraichir(); // la notification d'achat vient du serveur

    ///
    ///
    ///
    AlertService.instance.planifierPour(billetCree);

    // NotificationStore.instance.add(
    //   NotificationItem(
    //     id: 'achat-$reference',
    //     type: NotifType.achat,
    //     title: 'Billet confirmé',
    //     body:
    //         '${widget.compagnie.name} — ${widget.depart} → ${widget.arrivee}, le ${widget.date.day}/${widget.date.month} à ${widget.hour}.',
    //     date: DateTime.now(),
    //     billetReference: reference,
    //   ),
    // );
    // NotificationStore.instance.add(
    //   NotificationItem(
    //     id: 'rappel-$reference',
    //     type: NotifType.rappel,
    //     title: 'Rappel de départ',
    //     body:
    //         'N\'oubliez pas votre trajet ${widget.compagnie.name} du ${widget.date.day}/${widget.date.month} à ${widget.hour} — soyez à la gare 30 min avant.',
    //     date: DateTime.now(),
    //     billetReference: reference,
    //   ),
    // );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConfirmationPaiement(billet: billetCree),
      ),
    );
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  String _texteErreurAchat(ApiException e) {
    if (e.statusCode == 409) {
      final restantes = e.corps?['places_restantes'];
      return restantes is int && restantes > 0
          ? 'Il ne reste que $restantes place(s) pour ce départ.'
          : 'Ce départ est complet.';
    }
    if (e.corps?['montant_attendu'] != null ||
        e.corps?['taxe_attendue'] != null) {
      return 'Les tarifs ont changé. Revenez en arrière et recommencez la réservation.';
    }
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepIndicator(),
                        const SizedBox(height: 24),
                        const Text(
                          'Choisissez un moyen de paiement',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOperatorGrid(),
                        if (_selected != null) ...[
                          const SizedBox(height: 24),
                          _selected!.kind == PaymentKind.mobileMoney
                              ? _buildPhoneForm()
                              : _buildCardForm(),
                        ],
                        // const SizedBox(height: 28),
                        // _buildPayButton(),
                        const SizedBox(height: 20),
                        if (_step == _Step.taxe) ...[
                          const AvertissementFrais(),
                          const SizedBox(height: 14),
                        ],
                        _buildPayButton(),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Paiement sécurisé — vos informations ne sont jamais partagées.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── En-tête ─────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: _processing
                ? null
                : () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Paiement',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              'Total à régler : ${Tarif.format(_montantTotal)}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Indicateur des 2 étapes ─────────────

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(
          child: _buildStepChip(
            '1. Taxe',
            Tarif.format(widget.taxe),
            _Step.taxe,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStepChip(
            '2. Transport',
            Tarif.format(widget.montantTransport),
            _Step.transport,
          ),
        ),
      ],
    );
  }

  Widget _buildStepChip(String label, String amount, _Step step) {
    final active = _step == step;
    final done = _step == _Step.transport && step == _Step.taxe;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        gradient: active ? AppColors.buttonGradient : null,
        color: active ? null : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? Colors.transparent : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (done)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          Flexible(
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.white : AppColors.textMuted,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: active ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── Grille des opérateurs ─────────────

  Widget _buildOperatorGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [for (final op in kOperateurs) _buildOperatorTile(op)],
    );
  }

  Widget _buildOperatorTile(OperateurPaiement op) {
    final selected = _selected?.id == op.id;
    return GestureDetector(
      onTap: () => setState(() => _selected = op),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            BrandLogo(source: op.logo, size: 32, fallbackColor: op.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                op.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.secondary,
              ),
          ],
        ),
      ),
    );
  }

  // ───────────── Formulaire mobile money ─────────────

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro ${_selected!.name}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _fieldDecoration(
            'Ex : 70 12 34 56',
            Icons.phone_outlined,
          ),
          validator: (v) {
            final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
            if (digits.length != 8) return 'Numéro à 8 chiffres requis';
            return null;
          },
        ),
      ],
    );
  }

  // ───────────── Formulaire carte bancaire ─────────────

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coordonnées de la carte',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _cardNameController,
          textCapitalization: TextCapitalization.words,
          decoration: _fieldDecoration(
            'Nom du titulaire',
            Icons.person_outline,
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: _fieldDecoration(
            'Numéro de carte',
            Icons.credit_card_outlined,
          ),
          validator: (v) {
            final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
            if (digits.length < 12 || digits.length > 19) {
              return 'Numéro invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cardExpiryController,
                keyboardType: TextInputType.datetime,
                decoration: _fieldDecoration('MM/AA', Icons.event_outlined),
                validator: (v) => RegExp(r'^\d{2}/\d{2}$').hasMatch(v ?? '')
                    ? null
                    : 'Format MM/AA',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cardCvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: _fieldDecoration('CVV', Icons.lock_outline),
                validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                    ? null
                    : '3-4 chiffres',
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
    final radius = BorderRadius.circular(12);
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  // ───────────── Bouton Payer ─────────────

  Widget _buildPayButton() {
    final radius = BorderRadius.circular(8);
    final label = _step == _Step.taxe
        ? 'Payer la taxe (${Tarif.format(widget.taxe)})'
        : 'Payer le transport (${Tarif.format(widget.montantTransport)})';

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: AppColors.buttonGradient,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: _processing ? null : _onPay,
            child: Center(
              child: _processing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
