enum TemplateInstallationStatus { installed, uninstalled }

enum TemplateUninstallChoice {
  preserveRecords,
  archiveRecords,
  exportThenDelete,
  deleteRecords,
}

class TemplateDefinition {
  const TemplateDefinition({
    required this.key,
    required this.name,
    required this.description,
    required this.version,
    this.configurationJson = '{}',
  });

  final String key;
  final String name;
  final String description;
  final String version;
  final String configurationJson;
}

class TemplateInstallation {
  const TemplateInstallation({
    required this.id,
    required this.templateKey,
    required this.templateVersion,
    required this.installedAt,
    required this.updatedAt,
    required this.configurationSnapshotJson,
    required this.status,
    this.uninstallChoice,
    this.uninstalledAt,
  });

  final String id;
  final String templateKey;
  final String templateVersion;
  final DateTime installedAt;
  final DateTime updatedAt;
  final String configurationSnapshotJson;
  final TemplateInstallationStatus status;
  final TemplateUninstallChoice? uninstallChoice;
  final DateTime? uninstalledAt;

  bool get isInstalled => status == TemplateInstallationStatus.installed;
}

class TemplateInstallRequest {
  const TemplateInstallRequest({required this.templateKey});

  final String templateKey;
}

class TemplateUninstallRequest {
  const TemplateUninstallRequest({
    required this.templateKey,
    required this.choice,
  });

  final String templateKey;
  final TemplateUninstallChoice choice;
}

class TemplatesSnapshot {
  const TemplatesSnapshot({
    this.definitions = const [],
    this.installations = const [],
  });

  final List<TemplateDefinition> definitions;
  final List<TemplateInstallation> installations;

  bool get isEmpty => definitions.isEmpty && installations.isEmpty;

  bool isInstalled(String templateKey) {
    return installations.any(
      (installation) =>
          installation.templateKey == templateKey && installation.isInstalled,
    );
  }
}
