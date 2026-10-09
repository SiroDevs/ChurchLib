// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'field_pointer_arrow.dart';

class NumberResultsGrid extends StatelessWidget {
  const NumberResultsGrid({
    super.key,
    required this.fieldIndex,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int fieldIndex;
  final List<String> labels;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        FieldPointerArrow(fieldIndex: fieldIndex),
        Material(
          color: scheme.surface,
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisExtent: 44,
              ),
              itemCount: labels.length,
              itemBuilder: (_, i) => _NumberCell(
                label: labels[i],
                isSelected: i == selectedIndex,
                onTap: () => onSelect(i),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberCell extends StatelessWidget {
  const _NumberCell({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: isSelected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
