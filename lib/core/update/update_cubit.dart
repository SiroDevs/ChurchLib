// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'update_checker.dart';

part 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit() : super(const UpdateState());

  static const _every = Duration(hours: 6);
  Timer? _timer;

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(_every, (_) => check());
    check();
  }

  Future<void> check() async {
    final release = await fetchLatestRelease();
    if (release == null || isClosed) return;
    final current = (await PackageInfo.fromPlatform()).version;
    if (isClosed) return;

    if (!isNewerVersion(release.version, current)) {
      emit(UpdateState(
        status: UpdateStatus.upToDate,
        current: current,
        latest: release.version,
        releaseUrl: release.pageUrl,
      ));
      return;
    }

    final host = HostPlatform.detect();
    final asset = host == null ? null : pickAsset(release.assets, host);
    emit(UpdateState(
      status: UpdateStatus.available,
      current: current,
      latest: release.version,
      downloadUrl: asset?.url ?? release.pageUrl,
      fileName: asset?.name ?? '',
      releaseUrl: release.pageUrl,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
