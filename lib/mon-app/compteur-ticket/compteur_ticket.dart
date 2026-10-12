import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

/// Résultat de la sélection : nombre de tickets et les noms associés.
/// 1 ou 2 tickets : seul le nom de l'acheteur est demandé (le 2e ticket
/// est étiqueté "Accompagnant"). Plus de 2 : un nom par ticket.
class TicketSelection {
  const TicketSelection({required this.count, required this.names});
  final int count;
  final List<String> names;
}

class TicketCountSelector extends StatefulWidget {
  const TicketCountSelector({
    super.key,
    this.initialCount = 1,
    required this.buyerName,
    required this.onChanged,
  });

  final int initialCount;
  final String buyerName;
  final ValueChanged<TicketSelection> onChanged;

  @override
  State<TicketCountSelector> createState() => _TicketCountSelectorState();
}

class _TicketCountSelectorState extends State<TicketCountSelector> {
  late int _count;
  // late TextEditingController _buyerController;
  late final String _buyerName;
  final List<TextEditingController> _extraControllers = [];

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    // _buyerController = TextEditingController(text: widget.buyerName);
    _buyerName = widget.buyerName.trim().isEmpty
        ? 'Acheteur'
        : widget.buyerName.trim();
    _syncExtra();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  @override
  void dispose() {
    for (final c in _extraControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncExtra() {
    final needed = _count > 1 ? _count - 1 : 0;
    while (_extraControllers.length < needed) {
      _extraControllers.add(TextEditingController());
    }
    while (_extraControllers.length > needed) {
      _extraControllers.removeLast().dispose();
    }
  }

  void _notify() {
    // final buyer = _buyerController.text.trim().isEmpty
    //     ? 'Acheteur'
    //     : _buyerController.text.trim();
    // final names = <String>[buyer];
    final names = <String>[_buyerName];
    for (final c in _extraControllers) {
      names.add(c.text.trim().isEmpty ? 'Voyageur' : c.text.trim());
    }
    widget.onChanged(TicketSelection(count: _count, names: names));
  }

  void _update(int delta) {
    setState(() {
      _count = (_count + delta).clamp(1, 20);
      _syncExtra();
    });
    _notify();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildCounter(),
  //       const SizedBox(height: 14),
  //       _buildBuyerField(),
  //       if (_count > 2) ...[
  //         const SizedBox(height: 14),
  //         const Text(
  //           'Noms des autres voyageurs',
  //           style: TextStyle(
  //             fontSize: 13,
  //             fontWeight: FontWeight.w700,
  //             color: AppColors.textDark,
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         for (var i = 0; i < _extraControllers.length; i++)
  //           _buildExtraField(i),
  //       ],
  //     ],
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCounter(),
        const SizedBox(height: 14),
        _buildBuyerInfo(),
        if (_count > 1) ...[
          const SizedBox(height: 14),
          const Text(
            'Noms des autres voyageurs',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _extraControllers.length; i++)
            _buildExtraField(i),
        ],
      ],
    );
  }

  Widget _buildCounter() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Nombre de tickets',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _roundButton(Icons.remove, () => _update(-1)),
          SizedBox(
            width: 32,
            child: Text(
              '$_count',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          _roundButton(Icons.add, () => _update(1)),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.buttonGradient,
        ),
        child: Icon(icon, size: 16, color: AppColors.white),
      ),
    );
  }

  // Widget _buildBuyerField() {
  //   return TextField(
  //     controller: _buyerController,
  //     textCapitalization: TextCapitalization.words,
  //     onChanged: (_) => _notify(),
  //     style: const TextStyle(color: AppColors.textDark, fontSize: 14),
  //     decoration: InputDecoration(
  //       labelText: 'Votre nom',
  //       filled: true,
  //       fillColor: AppColors.white,
  //       isDense: true,
  //       contentPadding: const EdgeInsets.symmetric(
  //         horizontal: 14,
  //         vertical: 14,
  //       ),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: AppColors.border),
  //       ),
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: AppColors.border),
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: const BorderSide(color: AppColors.primary, width: 2),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBuyerInfo() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Titulaire du billet',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                Text(
                  widget.buyerName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: _extraControllers[index],
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => _notify(),
        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Voyageur ${index + 2}',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          filled: true,
          fillColor: AppColors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
