import 'package:flutter/material.dart';

import '../bibles/ui/bibles_screen.dart';

class BiblesSection extends StatelessWidget {
  const BiblesSection({super.key});

  @override
  Widget build(BuildContext context) => const BiblesScreen(embedded: true);
}
