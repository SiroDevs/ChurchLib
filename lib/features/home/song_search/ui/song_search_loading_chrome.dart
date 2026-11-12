part of 'song_search_loading.dart';

class _TitleBarSkeleton extends StatelessWidget {
  const _TitleBarSkeleton();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: kShellSidebarWidth,
        child: Row(
          children: [_block(28, 28), const SizedBox(width: 10), _block(90, 16)],
        ).padding(horizontal: 10),
      ),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    _block(14, 14),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: .55,
                        alignment: Alignment.centerLeft,
                        child: _block(double.infinity, 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _block(14, 14),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: .55,
                        alignment: Alignment.centerLeft,
                        child: _block(double.infinity, 14),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _block(24, 24),
                    const SizedBox(width: 8),
                    _block(24, 24),
                    const SizedBox(width: 10),
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

class _SidebarSkeleton extends StatelessWidget {
  const _SidebarSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 8),
      _navRow(),
      _navRow(),
      const Spacer(),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(78, 12),
            const SizedBox(height: 5),
            _block(68, 12),
            const SizedBox(height: 10),
            _block(double.infinity, 30),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Divider(height: 1),
      _navRow(),
      const Divider(height: 1),
      _navRow(),
      _navRow(),
      const Divider(height: 1),
      _navRow(),
      const SizedBox(height: 8),
    ],
  );
}

Widget _navRow() => Container(
  width: double.infinity,
  height: 50,
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    children: [_block(22, 22), const SizedBox(width: 18), _block(112, 13)],
  ),
);
