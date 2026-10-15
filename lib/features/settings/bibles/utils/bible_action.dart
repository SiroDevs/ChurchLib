// Flutter imports:
import 'package:flutter/material.dart';

const badgeOrange = Color(0xFFE1550F);
const mutedOrange = Color(0xFFB05A2E);
const darkBrown = Color(0xFF3A1300);
const onDark = Colors.white;

class BibleAction {
  const BibleAction(
    this.icon,
    this.label,
    this.onTap, {
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}
