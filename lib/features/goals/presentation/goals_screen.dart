import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'Goals',
      description: 'Connect direction, outcomes, and future progress reviews.',
      icon: Icons.flag_outlined,
    );
  }
}
