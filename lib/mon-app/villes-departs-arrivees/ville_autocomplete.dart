import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/villes-departs-arrivees/ville_transport.dart';

/// Champ de saisie de ville avec suggestions affichées sous le champ dès
/// 2 lettres tapées — pas besoin d'écrire le nom complet ("waga" suffit).
class VilleAutocomplete extends StatefulWidget {
  const VilleAutocomplete({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  State<VilleAutocomplete> createState() => _VilleAutocompleteState();
}

class _VilleAutocompleteState extends State<VilleAutocomplete> {
  List<String> _suggestions = [];
  bool _justSelected = false;

  void _onTextChanged(String value) {
    if (_justSelected) {
      _justSelected = false;
      return;
    }
    setState(() => _suggestions = suggestVilles(value));
    widget.onChanged(value);
  }

  void _select(String ville) {
    _justSelected = true;
    widget.controller.text = ville;
    widget.controller.selection = TextSelection.collapsed(offset: ville.length);
    setState(() => _suggestions = []);
    widget.onChanged(ville);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: AppColors.textMuted, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  onChanged: _onTextChanged,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (final v in _suggestions)
                  InkWell(
                    onTap: () => _select(v),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            v,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
