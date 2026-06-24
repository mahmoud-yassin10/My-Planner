import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/persistence_failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/services/id_service.dart';
import '../../../core/services/utc_clock.dart';
import 'bundled_template_definitions.dart';
import '../domain/template_models.dart';
import '../domain/template_repository.dart';

class DriftTemplateRepository implements TemplateRepository {
  const DriftTemplateRepository({
    required AppDatabase database,
    required IdService idService,
    required UtcClock clock,
    required AppLogger logger,
    required List<TemplateDefinition> definitions,
  }) : this._(database, idService, clock, logger, definitions);

  const DriftTemplateRepository._(
    this._database,
    this._idService,
    this._clock,
    this._logger,
    this._definitions,
  );

  final AppDatabase _database;
  final IdService _idService;
  final UtcClock _clock;
  final AppLogger _logger;
  final List<TemplateDefinition> _definitions;

  @override
  Future<TemplatesSnapshot> current() async {
    try {
      return await _snapshot();
    } catch (error, stackTrace) {
      _logFailure('current', error, stackTrace);
      throw const PersistenceReadFailure('Unable to read template data.');
    }
  }

  @override
  Stream<TemplatesSnapshot> watchTemplates() async* {
    yield await current();
    yield* _database
        .select(_database.templateInstallations)
        .watch()
        .skip(1)
        .asyncMap((_) => current())
        .handleError((Object error, StackTrace stackTrace) {
          _logFailure('watchTemplates', error, stackTrace);
          throw const PersistenceReadFailure('Unable to watch template data.');
        });
  }

  @override
  Future<TemplateInstallation> installTemplate(
    TemplateInstallRequest request,
  ) async {
    final definition = _definitionFor(request.templateKey);
    final existing = await _installedByKey(definition.key);
    if (existing != null) {
      throw const PersistenceValidationFailure(
        'Template is already installed.',
      );
    }

    final now = _clock.now();
    final installation = TemplateInstallation(
      id: _idService.newId(),
      templateKey: definition.key,
      templateVersion: definition.version,
      installedAt: now,
      updatedAt: now,
      configurationSnapshotJson: _configuration(definition.configurationJson),
      status: TemplateInstallationStatus.installed,
    );

    try {
      await _database
          .into(_database.templateInstallations)
          .insert(_installationCompanion(installation));
      return installation;
    } catch (error, stackTrace) {
      _logFailure('installTemplate', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to install template.');
    }
  }

  @override
  Future<TemplateInstallation> uninstallTemplate(
    TemplateUninstallRequest request,
  ) async {
    final previous = await _installedByKey(request.templateKey);
    if (previous == null) {
      throw const PersistenceValidationFailure('Template is not installed.');
    }

    final now = _clock.now();
    final installation = TemplateInstallation(
      id: previous.id,
      templateKey: previous.templateKey,
      templateVersion: previous.templateVersion,
      installedAt: previous.installedAt,
      updatedAt: now,
      configurationSnapshotJson: previous.configurationSnapshotJson,
      status: TemplateInstallationStatus.uninstalled,
      uninstallChoice: request.choice,
      uninstalledAt: now,
    );

    try {
      final count =
          await (_database.update(
            _database.templateInstallations,
          )..where((table) => table.id.equals(previous.id))).write(
            TemplateInstallationsCompanion(
              updatedAt: Value(installation.updatedAt),
              status: Value(installation.status.name),
              uninstallChoice: Value(installation.uninstallChoice?.name),
              uninstalledAt: Value(installation.uninstalledAt),
            ),
          );
      if (count == 0) {
        throw const PersistenceWriteFailure('Template installation not found.');
      }
      return installation;
    } catch (error, stackTrace) {
      _logFailure('uninstallTemplate', error, stackTrace);
      throw const PersistenceWriteFailure('Unable to uninstall template.');
    }
  }

  Future<TemplatesSnapshot> _snapshot() async {
    final rows =
        await (_database.select(_database.templateInstallations)..orderBy([
              (table) => OrderingTerm.asc(table.templateKey),
              (table) => OrderingTerm.asc(table.installedAt),
            ]))
            .get();

    return TemplatesSnapshot(
      definitions: _definitions.map(_validatedDefinition).toList(),
      installations: rows.map(_installationFromRow).toList(),
    );
  }

  Future<TemplateInstallation?> _installedByKey(String templateKey) async {
    final rows =
        await (_database.select(_database.templateInstallations)
              ..where((table) => table.templateKey.equals(templateKey))
              ..orderBy([(table) => OrderingTerm.desc(table.installedAt)]))
            .get();

    for (final row in rows) {
      final installation = _installationFromRow(row);
      if (installation.isInstalled) {
        return installation;
      }
    }
    return null;
  }

  TemplateDefinition _definitionFor(String templateKey) {
    final key = _templateKey(templateKey);
    for (final definition in _definitions.map(_validatedDefinition)) {
      if (definition.key == key) {
        return definition;
      }
    }
    throw const PersistenceValidationFailure('Template definition not found.');
  }

  TemplateDefinition _validatedDefinition(TemplateDefinition definition) {
    return TemplateDefinition(
      key: _templateKey(definition.key),
      name: _requiredText(definition.name, 'Template name'),
      description: _requiredText(
        definition.description,
        'Template description',
      ),
      version: _templateVersion(definition.version),
      configurationJson: _configuration(definition.configurationJson),
    );
  }

  TemplateInstallationsCompanion _installationCompanion(
    TemplateInstallation installation,
  ) {
    return TemplateInstallationsCompanion.insert(
      id: installation.id,
      templateKey: installation.templateKey,
      templateVersion: installation.templateVersion,
      installedAt: installation.installedAt,
      updatedAt: installation.updatedAt,
      configurationSnapshotJson: installation.configurationSnapshotJson,
      status: installation.status.name,
      uninstallChoice: Value(installation.uninstallChoice?.name),
      uninstalledAt: Value(installation.uninstalledAt),
    );
  }

  TemplateInstallation _installationFromRow(TemplateInstallationRow row) {
    return TemplateInstallation(
      id: row.id,
      templateKey: row.templateKey,
      templateVersion: row.templateVersion,
      installedAt: row.installedAt,
      updatedAt: row.updatedAt,
      configurationSnapshotJson: row.configurationSnapshotJson,
      status: _enumValue(
        TemplateInstallationStatus.values,
        row.status,
        TemplateInstallationStatus.installed,
      ),
      uninstallChoice: row.uninstallChoice == null
          ? null
          : _enumValue(
              TemplateUninstallChoice.values,
              row.uninstallChoice!,
              TemplateUninstallChoice.preserveRecords,
            ),
      uninstalledAt: row.uninstalledAt,
    );
  }

  String _templateKey(String value) {
    final key = _requiredText(value, 'Template key');
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(key)) {
      throw const PersistenceValidationFailure(
        'Template key must use lower-case letters, numbers, and underscores.',
      );
    }
    return key;
  }

  String _templateVersion(String value) {
    final version = _requiredText(value, 'Template version');
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
      throw const PersistenceValidationFailure(
        'Template version must use semantic version format.',
      );
    }
    return version;
  }

  String _configuration(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) {
      throw const PersistenceValidationFailure(
        'Template configuration must be a JSON object.',
      );
    }
    if (_containsForbiddenPayloadKey(decoded)) {
      throw const PersistenceValidationFailure(
        'Template infrastructure must not include example records.',
      );
    }
    return jsonEncode(decoded);
  }

  String _requiredText(String value, String label) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw PersistenceValidationFailure('$label must not be empty.');
    }
    return trimmed;
  }

  bool _containsForbiddenPayloadKey(Object? value) {
    const forbiddenKeys = {'records', 'exampleRecords', 'demoData'};
    if (value is Map) {
      for (final entry in value.entries) {
        if (forbiddenKeys.contains(entry.key)) {
          return true;
        }
        if (_containsForbiddenPayloadKey(entry.value)) {
          return true;
        }
      }
    }
    if (value is List) {
      return value.any(_containsForbiddenPayloadKey);
    }
    return false;
  }

  T _enumValue<T extends Enum>(List<T> values, String name, T fallback) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }

  void _logFailure(String operation, Object error, StackTrace stackTrace) {
    _logger.error(
      'templateRepository',
      operation,
      'Template repository operation failed.',
      metadata: {'errorType': error.runtimeType.toString()},
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final templateDefinitionsProvider = Provider<List<TemplateDefinition>>((ref) {
  return bundledTemplateDefinitions;
});

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return DriftTemplateRepository(
    database: ref.watch(appDatabaseProvider),
    idService: ref.watch(idServiceProvider),
    clock: ref.watch(utcClockProvider),
    logger: ref.watch(appLoggerProvider),
    definitions: ref.watch(templateDefinitionsProvider),
  );
});
