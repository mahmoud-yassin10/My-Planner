import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/shared/models/backup_contract.dart';
import 'package:momentum_os/shared/models/template_installation_contract.dart';
import 'package:momentum_os/shared/repositories/settings_repository.dart';

void main() {
  test('backup envelope round-trips Phase 2 settings payloads', () {
    final envelope = BackupEnvelope(
      version: backupEnvelopeVersion,
      exportedAtUtc: DateTime.utc(2026, 6, 24, 10),
      settings: AppSettingsPreferences.defaults.copyWith(
        themeMode: AppThemePreference.dark,
        localeTag: 'en',
      ),
    );

    final restored = BackupEnvelope.fromJson(envelope.toJson());

    expect(restored.version, backupEnvelopeVersion);
    expect(restored.exportedAtUtc.isUtc, isTrue);
    expect(restored.settings, envelope.settings);
  });

  test('template installation contract enforces future safety rules', () {
    const contract = TemplateInstallationContract(
      templateKey: 'generic-template',
      templateVersion: 1,
    );

    expect(contract.validate, returnsNormally);
  });

  test('template installation contract rejects unsafe definitions', () {
    const contract = TemplateInstallationContract(
      templateKey: '',
      templateVersion: 0,
    );

    expect(contract.validate, throwsA(isA<TemplateContractException>()));
  });
}
