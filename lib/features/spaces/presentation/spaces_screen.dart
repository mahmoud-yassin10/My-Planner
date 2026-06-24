import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class SpacesScreen extends StatelessWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'Spaces',
      description: 'Configure flexible workspaces without fixed assumptions.',
      icon: Icons.dashboard_customize_outlined,
    );
  }
}
