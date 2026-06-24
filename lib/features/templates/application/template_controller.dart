import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drift_template_repository.dart';
import '../domain/template_models.dart';
import '../domain/template_repository.dart';

class TemplateController {
  const TemplateController(this._repository);

  final TemplateRepository _repository;

  Future<TemplateInstallation> installTemplate(String templateKey) {
    return _repository.installTemplate(
      TemplateInstallRequest(templateKey: templateKey),
    );
  }

  Future<TemplateInstallation> uninstallTemplate(
    String templateKey,
    TemplateUninstallChoice choice,
  ) {
    return _repository.uninstallTemplate(
      TemplateUninstallRequest(templateKey: templateKey, choice: choice),
    );
  }
}

final templateControllerProvider = Provider<TemplateController>((ref) {
  return TemplateController(ref.watch(templateRepositoryProvider));
});

final templatesSnapshotProvider = StreamProvider<TemplatesSnapshot>((ref) {
  return ref.watch(templateRepositoryProvider).watchTemplates();
});
