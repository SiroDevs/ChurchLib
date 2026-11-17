part of 'update_cubit.dart';

enum UpdateStatus { unknown, upToDate, available }

class UpdateState extends Equatable {
  const UpdateState({
    this.status = UpdateStatus.unknown,
    this.current = '',
    this.latest = '',
    this.downloadUrl = '',
    this.fileName = '',
    this.checksumUrl = '',
    this.releaseUrl = '',
    this.checkSequence = 0,
  });

  final UpdateStatus status;

  final String current, latest;

  /// Direct link to the right installer for this machine; falls back to the release page
  /// when the release has no file for it.
  final String downloadUrl;

  /// Name of the file [downloadUrl] points to. Empty when it is just the release page.
  final String fileName;

  /// URL of the release checksum manifest.
  final String checksumUrl;

  final String releaseUrl;

  /// Changes after each completed check so settings changes can reprocess a release.
  final int checkSequence;

  bool get hasUpdate => status == UpdateStatus.available;

  @override
  List<Object?> get props => [
    status,
    current,
    latest,
    downloadUrl,
    fileName,
    checksumUrl,
    releaseUrl,
    checkSequence,
  ];
}
