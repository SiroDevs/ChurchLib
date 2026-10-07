// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/app_util.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_styles.dart';
import '../../../data/models/song/songbook.dart';
import '../../../domain/entities/basic_model.dart';

var locale = 'en';

class BookItem extends StatelessWidget {
  final Selectable<SongBook> item;
  final Function()? onPressed;

  const BookItem({super.key, required this.item, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.isSelected
          ? ThemeColors.primary
          : Theme.of(context).colorScheme.onInverseSurface,
      elevation: 5,
      child: Center(
        child: ListTile(
          onTap: onPressed,
          leading: Padding(
            padding: const EdgeInsets.all(Sizes.xs),
            child: Icon(
              item.isSelected
                  ? (Platform.isIOS ? Icons.check_circle : Icons.check_box)
                  : (Platform.isIOS
                        ? Icons.radio_button_unchecked
                        : Icons.check_box_outline_blank),
              color: item.isSelected
                  ? Colors.white
                  : ThemeColors.bgColorWB(context),
            ),
          ),
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
        ),
      ),
    );
  }
}

// ignore: must_be_immutable

// ignore: must_be_immutable
