// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../core/di/injectable.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/update/update_cubit.dart';

class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  final _cubit = getIt<UpdateCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.start();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateCubit, UpdateState>(
      bloc: _cubit,
      builder: (context, state) {
        if (!state.hasUpdate) return const SizedBox.shrink();
        final accent = ThemeColors.primary;
        return Container(
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: .5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.system_update_alt, size: 18, color: accent),
                  const SizedBox(width: 8),
                  const Text(
                    'Update available',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text('Version ${state.latest} is out (you have ${state.current}).'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => launchUrl(
                    Uri.parse(state.downloadUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download, size: 18),
                      const SizedBox(width: 8),
                      Text(state.fileName.isEmpty ? 'Get the update' : 'Download'),
                    ],
                  ),
                ),
              ),
              if (state.fileName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  state.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
