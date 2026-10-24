// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'update_checker.dart';

part 'update_state.dart';

/// Looks on GitHub for a newer version of the app: once when started, then
/// every few hours while the app stays open.
class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit() : super(const UpdateState());

  static const _every = Duration(hours: 6);
  Timer? _timer;

  /// Safe to call from several places; only the first call starts checking.
  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(_every, (_) => check());
    check();
  }

  Future<void> check() async {
    final latest = await fetchLatestVersion();
    // Offline or unreadable: keep whatever was known before.
    if (latest == null || isClosed) return;
    final current = (await PackageInfo.fromPlatform()).version;
    if (isClosed) return;
    emit(
      UpdateState(
        status: isNewerVersion(latest, current)
            ? UpdateStatus.available
            : UpdateStatus.upToDate,
        current: current,
        latest: latest,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
