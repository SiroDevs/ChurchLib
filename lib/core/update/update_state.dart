part of 'update_cubit.dart';

enum UpdateStatus { unknown, upToDate, available }

class UpdateState extends Equatable {
  const UpdateState({
    this.status = UpdateStatus.unknown,
    this.current = '',
    this.latest = '',
  });

  final UpdateStatus status;

  /// The version installed and the newest one on GitHub.
  final String current, latest;

  bool get hasUpdate => status == UpdateStatus.available;

  @override
  List<Object?> get props => [status, current, latest];
}
