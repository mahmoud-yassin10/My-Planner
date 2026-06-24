import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'AI Copilot',
      description: 'Structured AI assistance will be added in a later phase.',
      icon: Icons.auto_awesome_outlined,
    );
  }
}
