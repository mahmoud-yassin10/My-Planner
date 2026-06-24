import 'template_models.dart';

abstract interface class TemplateRepository {
  Future<TemplatesSnapshot> current();
  Stream<TemplatesSnapshot> watchTemplates();

  Future<TemplateInstallation> installTemplate(TemplateInstallRequest request);
  Future<TemplateInstallation> uninstallTemplate(
    TemplateUninstallRequest request,
  );
}
