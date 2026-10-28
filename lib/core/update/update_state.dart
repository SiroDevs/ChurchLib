part of 'update_cubit.dart';

enum UpdateStatus { unknown, upToDate, available }

class UpdateState extends Equatable {
  const UpdateState({
    this.status = UpdateStatus.unknown,
    this.current = '',
    this.latest = '',
    this.downloadUrl = '',
    this.fileName = '',
    this.releaseUrl = '',
  });

  final UpdateStatus status;

  final String current, latest;

  /// Direct link to the right installer for this machine; falls back to the release page
  /// when the release has no file for it.
  final String downloadUrl;

  /// Name of the file [downloadUrl] points to. Empty when it is just the release page.
  final String fileName;

  final String releaseUrl;

  bool get hasUpdate => status == UpdateStatus.available;

  @override
  List<Object?> get props =>
      [status, current, latest, downloadUrl, fileName, releaseUrl];
}
