import 'dart:io';

import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_styles.dart';
import '../../../data/models/song/songbook.dart';
import '../../../domain/entities/basic_model.dart';
import '../../utils/formatting/app_util.dart';

var locale = 'en';

class BookItem extends StatelessWidget {
  final Selectable<SongBook> item;
  final Function()? onPressed;

  const BookItem({super.key, required this.item, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: Icon(
        item.isSelected
            ? (Platform.isIOS ? Icons.check_circle : Icons.check_box)
            : (Platform.isIOS
                  ? Icons.radio_button_unchecked
                  : Icons.check_box_outline_blank),
        color: item.isSelected
            ? Colors.white
            : ThemeColors.bgColorWB(context),
      )
          .padding(all: Sizes.xs),
      title: Text(
        refineTitle(item.data.title!),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: item.isSelected
              ? Colors.white
              : ThemeColors.bgColorWB(context),
        ),
      ),
      subtitle: Text(
        "${item.data.songs!} ${item.data.subTitle} songs",
        style: TextStyle(
          fontSize: 18,
          color: item.isSelected
              ? Colors.white
              : ThemeColors.bgColorWB(context),
        ),
      ),
    )
        .center()
        .card(
          color: item.isSelected
              ? ThemeColors.primary
              : Theme.of(context).colorScheme.onInverseSurface,
          elevation: 5,
        );
  }
}

// ignore: must_be_immutable

// ignore: must_be_immutable
