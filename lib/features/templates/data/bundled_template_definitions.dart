import '../domain/template_models.dart';

const bundledTemplateDefinitions = <TemplateDefinition>[
  TemplateDefinition(
    key: 'freelancing_crm',
    name: 'Freelancing CRM',
    description: 'Configurable pipeline and work-tracking structure.',
    version: '1.0.0',
    configurationJson:
        '{"category":"work","spaces":[{"key":"pipeline","recordTypes":["pipeline_item","deliverable","agreement"]}]}',
  ),
  TemplateDefinition(
    key: 'finance',
    name: 'Finance',
    description:
        'Configurable money-tracking structure without default currency.',
    version: '1.0.0',
    configurationJson:
        '{"category":"finance","spaces":[{"key":"finance","recordTypes":["account","transaction","budget"]}]}',
  ),
  TemplateDefinition(
    key: 'opportunities',
    name: 'Opportunities',
    description: 'Configurable opportunity and follow-up structure.',
    version: '1.0.0',
    configurationJson:
        '{"category":"opportunities","spaces":[{"key":"opportunities","recordTypes":["opportunity","organization","follow_up"]}]}',
  ),
  TemplateDefinition(
    key: 'learning',
    name: 'Learning',
    description: 'Configurable study and knowledge-progress structure.',
    version: '1.0.0',
    configurationJson:
        '{"category":"learning","spaces":[{"key":"learning","recordTypes":["topic","resource","review"]}]}',
  ),
  TemplateDefinition(
    key: 'competitive_programming',
    name: 'Competitive Programming',
    description: 'Configurable practice and problem-solving structure.',
    version: '1.0.0',
    configurationJson:
        '{"category":"practice","spaces":[{"key":"practice","recordTypes":["problem","concept","session"]}]}',
  ),
  TemplateDefinition(
    key: 'machine_learning',
    name: 'Machine Learning',
    description: 'Configurable experiment and model-learning structure.',
    version: '1.0.0',
    configurationJson:
        '{"category":"experiments","spaces":[{"key":"experiments","recordTypes":["dataset","experiment","model"]}]}',
  ),
  TemplateDefinition(
    key: 'university',
    name: 'University',
    description:
        'Configurable academic planning structure without fixed courses.',
    version: '1.0.0',
    configurationJson:
        '{"category":"education","spaces":[{"key":"academics","recordTypes":["module","assignment","exam"]}]}',
  ),
  TemplateDefinition(
    key: 'fitness',
    name: 'Fitness',
    description: 'Configurable health and training structure.',
    version: '1.0.0',
    configurationJson:
        '{"category":"health","spaces":[{"key":"fitness","recordTypes":["session","measurement","routine"]}]}',
  ),
  TemplateDefinition(
    key: 'reading',
    name: 'Reading',
    description: 'Configurable reading and notes structure.',
    version: '1.0.0',
    configurationJson:
        '{"category":"knowledge","spaces":[{"key":"reading","recordTypes":["book","source","note"]}]}',
  ),
  TemplateDefinition(
    key: 'content_creation',
    name: 'Content Creation',
    description: 'Configurable publishing and idea-development structure.',
    version: '1.0.0',
    configurationJson:
        '{"category":"publishing","spaces":[{"key":"content","recordTypes":["idea","asset","publication"]}]}',
  ),
];
