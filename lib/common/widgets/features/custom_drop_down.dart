import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

class CustomDropdownItem extends StatelessWidget {
  final String value;
  final String selectedOption;

  const CustomDropdownItem({
    super.key,
    required this.value,
    required this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = value == selectedOption;
    return Text(
      value,
      style: TextStyle(
        fontSize: 16,
        color: isSelected ? Colors.white : Colors.black,
      ),
    )
        .padding(all: 10)
        .decorated(color: isSelected ? Colors.blue : Colors.white);
  }
}
