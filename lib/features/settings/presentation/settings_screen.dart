import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'Settings',
      description: 'App configuration will be available in a later phase.',
      icon: Icons.settings_outlined,
    );
  }
}
