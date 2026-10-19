import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kmaa_e_tickets/mon-app/Apis_service/apis_service.dart';
import 'package:kmaa_e_tickets/mon-app/billet/billet.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/menu.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  void _onMenuSelect(BuildContext context, MenuItem item) =>
      AppRoutes.navigateFromMenu(context, item);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ValueListenableBuilder<UserProfile?>(
            valueListenable: UserStore.instance.profile,
            builder: (context, profile, _) {
              final p = profile ?? const UserProfile(prenom: '', nom: '');
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  _buildHeader(context, p),
                  const SizedBox(height: 24),
                  _buildSection('Compte', [
                    _buildTile(
                      Icons.person_outline,
                      'Mes informations',
                      () => _editIdentite(context, p),
                    ),
                    _buildTile(
                      Icons.confirmation_number_outlined,
                      'Mes billets',
                      () => Navigator.of(context).pushNamed(AppRoutes.billets),
                    ),
                    _buildTile(
                      Icons.wallet_outlined,
                      'Moyens de paiement utilisés',
                      () => _showMoyensPaiement(context),
                    ),
                    // _buildSwitchTile(
                    //   Icons.notifications_active_outlined,
                    //   'Rappels de départ',
                    //   p.recevoirRappels,
                    //   (v) => UserStore.instance.save(
                    //     p.copyWith(recevoirRappels: v),
                    //   ),
                    // ),
                    // if (kDebugMode)
                    // _buildTile(
                    //   Icons.qr_code_scanner,
                    //   'Vérifier un ticket (agent)',
                    //   () => Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (_) => const VerifierBilletScreen(),
                    //     ),
                    //   ),
                    // ),
                    //agent verification pour le moment
                    // _buildTile(
                    //   Icons.qr_code_scanner,
                    //   'Vérifier un ticket (agent)',
                    //   () => Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (_) => const VerifierBilletScreen(),
                    //     ),
                    //   ),
                    // ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('Application', [
                    _buildTile(
                      Icons.language_outlined,
                      'Langue',
                      () {},
                      trailing: 'Français',
                    ),
                    _buildTile(
                      Icons.help_outline,
                      'Aide & Support',
                      () => _showAide(context),
                    ),
                    _buildTile(
                      Icons.info_outline,
                      'À propos',
                      () => _showAPropos(context),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: Menu(
          current: MenuItem.profil,
          onSelect: (i) => _onMenuSelect(context, i),
        ),
      ),
    );
  }

  // ───────────── En-tête ─────────────

  Widget _buildHeader(BuildContext context, UserProfile p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              p.initiales,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nomComplet.isEmpty ? 'Voyageur' : p.nomComplet,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.telephone.isEmpty
                      ? 'Ajouter un numéro de téléphone'
                      : p.telephone,
                  style: const TextStyle(color: AppColors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editIdentite(context, p),
            icon: const Icon(Icons.edit, color: AppColors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ───────────── Sections ─────────────

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.border),
                tiles[i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    String? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.secondary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ───────────── Déconnexion ─────────────

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          await UserStore.instance.deconnecter();
          if (!context.mounted) return;
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ───────────── Édition des informations ─────────────

  void _editIdentite(BuildContext context, UserProfile p) {
    final prenomCtrl = TextEditingController(text: p.prenom);
    final nomCtrl = TextEditingController(text: p.nom);
    final telCtrl = TextEditingController(text: p.telephone);
    final emailCtrl = TextEditingController(text: p.email);
    var enCours = false;
    String? erreur;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes informations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: prenomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: telCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    helperText:
                        'Ce numéro sert à vous connecter : il ne peut pas être modifié ici.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (facultatif, gardé sur cet appareil)',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (erreur != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    erreur!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: AppColors.buttonGradient,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: enCours
                            ? null
                            : () async {
                                final prenom = prenomCtrl.text.trim();
                                final nom = nomCtrl.text.trim();
                                if (prenom.length < 2 || nom.length < 2) {
                                  setSheet(
                                    () => erreur =
                                        'Prénom et nom : 2 caractères minimum.',
                                  );
                                  return;
                                }

                                setSheet(() {
                                  enCours = true;
                                  erreur = null;
                                });
                                try {
                                  await ApiService.instance.modifierProfil(
                                    prenom: prenom,
                                    nom: nom,
                                  );
                                  await UserStore.instance.save(
                                    p.copyWith(
                                      prenom: prenom,
                                      nom: nom,
                                      email: emailCtrl.text.trim(),
                                    ),
                                  );
                                  if (sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                } on ApiException catch (e) {
                                  if (sheetContext.mounted) {
                                    setSheet(() {
                                      enCours = false;
                                      erreur = e.message;
                                    });
                                  }
                                }
                              },
                        child: Center(
                          child: enCours
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text(
                                  'Enregistrer',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────── Moyens de paiement (dérivés des vrais achats) ─────────────

  void _showMoyensPaiement(BuildContext context) {
    final billets = TicketStore.instance.billets.value;
    final operateurs = <String, int>{};
    for (final b in billets) {
      operateurs[b.operateur.name] = (operateurs[b.operateur.name] ?? 0) + 1;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Moyens de paiement utilisés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            if (operateurs.isEmpty)
              const Text(
                'Aucun paiement effectué pour le moment.',
                style: TextStyle(color: AppColors.textMuted),
              )
            else
              for (final entry in operateurs.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value} paiement(s)',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // ───────────── Aide et à propos ─────────────

  void _showAide(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aide & Support'),

        content: const Text(
          'Pour toute question, contactez notre support au 54 78 55 55/72 53 46 46 ou par email à admini@convergesas.com.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAPropos(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('À propos'),
        content: const Text(
          'Converge SAS — Version 1.0.0\nVotre compagnon de voyage au Burkina Faso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
