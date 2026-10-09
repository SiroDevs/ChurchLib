// Flutter imports:
import 'package:flutter/material.dart';

class ScriptureField extends StatelessWidget {
  const ScriptureField({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = isActive ? scheme.primary : scheme.outline;
    final labelColor = isActive ? scheme.primary : scheme.onSurfaceVariant;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: isActive
            ? scheme.primaryContainer.withValues(alpha: 0.4)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: enabled ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: accent, width: isActive ? 2 : 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
