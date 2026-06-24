class TemplateInstallationContract {
  const TemplateInstallationContract({
    required this.templateKey,
    required this.templateVersion,
    this.requiresIdempotentInstall = true,
    this.requiresTransactionalApplication = true,
    this.installedDataMustRemainUserEditable = true,
  });

  final String templateKey;
  final int templateVersion;
  final bool requiresIdempotentInstall;
  final bool requiresTransactionalApplication;
  final bool installedDataMustRemainUserEditable;

  void validate() {
    if (templateKey.trim().isEmpty) {
      throw const TemplateContractException('Template key must not be empty.');
    }

    if (templateVersion <= 0) {
      throw const TemplateContractException(
        'Template version must be a positive integer.',
      );
    }

    if (!requiresIdempotentInstall ||
        !requiresTransactionalApplication ||
        !installedDataMustRemainUserEditable) {
      throw const TemplateContractException(
        'Template contracts must be idempotent, transactional, and editable.',
      );
    }
  }
}

class TemplateContractException implements Exception {
  const TemplateContractException(this.message);

  final String message;

  @override
  String toString() => 'TemplateContractException($message)';
}
