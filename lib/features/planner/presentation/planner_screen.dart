import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'Planner',
      description: 'Plan time, review commitments, and organize execution.',
      icon: Icons.calendar_today_outlined,
    );
  }
}
