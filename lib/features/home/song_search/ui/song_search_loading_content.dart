part of 'song_search_loading.dart';

class _SongListSkeleton extends StatelessWidget {
  const _SongListSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_chip(68), _chip(76), _chip(58), _chip(72)],
        ).padding(horizontal: 5),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.only(left: 5, right: 10),
          itemCount: 7,
          separatorBuilder: (_, _) => const SizedBox(height: 3),
          itemBuilder: (_, index) => _SongRowSkeleton(
            hasChorus: index.isEven,
          ),
        ),
      ),
    ],
  );
}

class _SongRowSkeleton extends StatelessWidget {
  const _SongRowSkeleton({required this.hasChorus});

  final bool hasChorus;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 53,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _block(double.infinity, 13)),
              const SizedBox(width: 10),
              _block(28, 13),
              if (hasChorus) ...[
                const SizedBox(width: 6),
                _block(40, 13),
              ],
              const SizedBox(width: 6),
              _block(14, 14),
            ],
          ),
          const SizedBox(height: 3),
          _block(double.infinity, 1),
          const SizedBox(height: 3),
          _block(double.infinity, 10),
          const SizedBox(height: 3),
          FractionallySizedBox(
            widthFactor: .68,
            alignment: Alignment.centerLeft,
            child: _block(double.infinity, 9),
          ),
        ],
      ),
    ),
  );
}

class _SongViewSkeleton extends StatelessWidget {
  const _SongViewSkeleton();

  static const _stanzaWidths = [
    [1.0, .82, .94, .74, .9, .63, .52],
    [1.0, .91, .8, .96, .68, .53],
    [1.0, .77, .62],
    [1.0, .89, .94, .74, .83, .64, .58],
    [1.0, .82, .97, .79, .9, .67, .48],
  ];

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(vertical: 5),
    children: [
      for (final stanza in _stanzaWidths)
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final widthFactor in stanza)
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  alignment: Alignment.centerLeft,
                  child: _block(double.infinity, 14),
                ).padding(bottom: 5),
            ],
          ),
        ),
    ],
  );
}

Widget _chip(double width) => _block(
  width,
  25,
).decorated(borderRadius: BorderRadius.circular(5)).padding(right: 5);

Widget _block(double width, double height) =>
    Container(width: width, height: height, color: Colors.black);
