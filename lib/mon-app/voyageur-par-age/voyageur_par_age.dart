import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';

enum TravelerCategory { enfant, jeune, adulte }

extension TravelerCategoryX on TravelerCategory {
  String get label => switch (this) {
    TravelerCategory.enfant => 'Enfant (0-5 ans)',
    TravelerCategory.jeune => 'Jeune (6-15 ans)',
    TravelerCategory.adulte => 'Adulte (16 ans et +)',
  };

  (int, int) get ageRange => switch (this) {
    TravelerCategory.enfant => (0, 5),
    TravelerCategory.jeune => (6, 15),
    TravelerCategory.adulte => (16, 120),
  };
}

class TravelerInfo {
  const TravelerInfo({required this.name, required this.age});
  final String name;
  final int age;
}

class TravelersSelection {
  const TravelersSelection({required this.total, required this.details});
  final int total;
  final Map<TravelerCategory, List<TravelerInfo>> details; // vide si total ≤ 2
}

class TravelersSelector extends StatefulWidget {
  const TravelersSelector({
    super.key,
    this.initialCount = 1,
    required this.onChanged,
  });

  final int initialCount;
  final ValueChanged<TravelersSelection> onChanged;

  @override
  State<TravelersSelector> createState() => _TravelersSelectorState();
}

class _TravelersSelectorState extends State<TravelersSelector> {
  late int _count;
  final Map<TravelerCategory, List<TravelerInfo>> _details = {
    for (final c in TravelerCategory.values) c: [],
  };

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    _notify();
  }

  int get _assigned => _details.values.fold(0, (sum, l) => sum + l.length);
  // bool get _needsDetails => _count > 2;
  bool get _needsDetails => _count >= 2;

  void _notify() {
    widget.onChanged(
      TravelersSelection(
        total: _count,
        details: _needsDetails ? _details : const {},
      ),
    );
  }

  void _updateCount(int delta) {
    setState(() {
      _count = (_count + delta).clamp(1, 20);
      if (!_needsDetails) {
        for (final l in _details.values) {
          l.clear();
        }
      }
    });
    _notify();
  }

  Future<void> _editCategory(TravelerCategory category) async {
    final maxForCategory = _count - (_assigned - _details[category]!.length);
    final result = await showModalBottomSheet<List<TravelerInfo>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategorySheet(
        category: category,
        maxCount: maxForCategory,
        initial: _details[category]!,
      ),
    );
    if (result != null) {
      setState(() => _details[category] = result);
      _notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCounterRow(),
        if (_needsDetails) ...[const SizedBox(height: 12), _buildBreakdown()],
      ],
    );
  }

  Widget _buildCounterRow() {
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
            Icons.people_outline,
            color: AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Voyageurs',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _roundIconButton(Icons.remove, () => _updateCount(-1)),
          SizedBox(
            width: 32,
            child: Text(
              '$_count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          _roundIconButton(Icons.add, () => _updateCount(1)),
        ],
      ),
    );
  }

  Widget _buildBreakdown() {
    final complete = _assigned == _count;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10,
            bottom: 10,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 4,
              top: 6,
              bottom: 6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final category in TravelerCategory.values)
                  _buildCategoryRow(category),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Text(
                    complete
                        ? 'Répartition complète ✓'
                        : 'Reste à renseigner : ${_count - _assigned} voyageur(s)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: complete ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(TravelerCategory category) {
    final list = _details[category]!;
    return InkWell(
      onTap: () => _editCategory(category),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    list.isEmpty
                        ? 'Aucun voyageur'
                        : list
                              .map((t) => '${t.name} (${t.age} ans)')
                              .join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${list.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _roundIconButton(IconData icon, VoidCallback onTap) {
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

// ───────────── Formulaire d'une tranche d'âge ─────────────

class _CategorySheet extends StatefulWidget {
  const _CategorySheet({
    required this.category,
    required this.maxCount,
    required this.initial,
  });

  final TravelerCategory category;
  final int maxCount;
  final List<TravelerInfo> initial;

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late int _count;
  late List<TextEditingController> _names;
  late List<TextEditingController> _ages;

  @override
  void initState() {
    super.initState();
    _count = widget.initial.length.clamp(0, widget.maxCount);
    _names = [
      for (var i = 0; i < _count; i++)
        TextEditingController(text: widget.initial[i].name),
    ];
    _ages = [
      for (var i = 0; i < _count; i++)
        TextEditingController(text: '${widget.initial[i].age}'),
    ];
  }

  @override
  void dispose() {
    for (final c in _names) {
      c.dispose();
    }
    for (final c in _ages) {
      c.dispose();
    }
    super.dispose();
  }

  void _setCount(int value) {
    final clamped = value.clamp(0, widget.maxCount);
    setState(() {
      while (_names.length < clamped) {
        _names.add(TextEditingController());
        _ages.add(TextEditingController());
      }
      while (_names.length > clamped) {
        _names.removeLast().dispose();
        _ages.removeLast().dispose();
      }
      _count = clamped;
    });
  }

  void _submit() {
    if (_count > 0 && !(_formKey.currentState?.validate() ?? false)) return;
    final result = [
      for (var i = 0; i < _count; i++)
        TravelerInfo(
          name: _names[i].text.trim().isEmpty
              ? 'Voyageur ${i + 1}'
              : _names[i].text.trim(),
          age: int.tryParse(_ages[i].text) ?? widget.category.ageRange.$1,
        ),
    ];
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final (min, max) = widget.category.ageRange;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.category.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Âge attendu : $min à $max ans',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nombre de personnes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      _roundIconButton(
                        Icons.remove,
                        () => _setCount(_count - 1),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$_count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _roundIconButton(Icons.add, () => _setCount(_count + 1)),
                    ],
                  ),
                  if (widget.maxCount == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Aucune place restante — modifiez une autre tranche.',
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var i = 0; i < _count; i++)
                            _buildPersonFields(i, min, max),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          onTap: _submit,
                          child: const Center(
                            child: Text(
                              'Valider',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
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
      ),
    );
  }

  Widget _buildPersonFields(int index, int min, int max) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _names[index],
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _ages[index],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Âge',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final age = int.tryParse(v ?? '');
                if (age == null) return 'Requis';
                if (age < min || age > max) return '$min-$max';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
