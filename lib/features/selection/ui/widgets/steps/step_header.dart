// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/theme/theme_colors.dart';
import '../../../bloc/selection_bloc.dart';

class StepHeader extends StatelessWidget {
  final SelectionState flow;
  const StepHeader({super.key, required this.flow});

  @override
  Widget build(BuildContext context) {
    final steps = flow.steps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                _Dot(
                  number: i + 1,
                  done: i < flow.index,
                  active: i == flow.index,
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < flow.index
                          ? ThemeColors.primary
                          : ThemeColors.lightGrey,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${flow.index + 1} of ${steps.length}'
            ' · ${steps[flow.index].label}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ThemeColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int number;
  final bool done;
  final bool active;
  const _Dot({required this.number, required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    final filled = done || active;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? ThemeColors.primary : Colors.transparent,
        border: Border.all(
          color: filled ? ThemeColors.primary : ThemeColors.lightGrey,
          width: 2,
        ),
      ),
      child: done
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : Text(
              '$number',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : ThemeColors.mediumGrey,
              ),
            ),
    );
  }
}
