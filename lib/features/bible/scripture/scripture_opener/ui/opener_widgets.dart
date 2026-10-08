part of 'scripture_opener_screen.dart';

class _FieldButton extends StatelessWidget {
  final String label;
  final String value;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _FieldButton({
    required this.label,
    required this.value,
    this.enabled = true,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ThemeColors.lightGrey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Select $label'.toLowerCase() : value,
                    style: TextStyle(
                      fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.chevron_right, color: ThemeColors.mediumGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  final ScriptureSearchRowState row;
  const _LockedRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: ThemeColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(row.reference)),
        ],
      ),
    );
  }
}
