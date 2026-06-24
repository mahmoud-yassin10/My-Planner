import '../repositories/settings_repository.dart';

const backupEnvelopeVersion = 1;

class BackupEnvelope {
  const BackupEnvelope({
    required this.version,
    required this.exportedAtUtc,
    required this.settings,
  });

  final int version;
  final DateTime exportedAtUtc;
  final AppSettingsPreferences settings;

  Map<String, Object?> toJson() {
    return {
      'version': version,
      'exportedAtUtc': exportedAtUtc.toUtc().toIso8601String(),
      'settings': settings.toJson(),
    };
  }

  factory BackupEnvelope.fromJson(Map<String, Object?> json) {
    return BackupEnvelope(
      version: json['version'] as int,
      exportedAtUtc: DateTime.parse(json['exportedAtUtc'] as String).toUtc(),
      settings: AppSettingsPreferences.fromJson(
        (json['settings'] as Map).cast<String, Object?>(),
      ),
    );
  }
}

abstract interface class BackupSerializable<T> {
  Map<String, Object?> toBackupJson(T value);

  T fromBackupJson(Map<String, Object?> json);
}
