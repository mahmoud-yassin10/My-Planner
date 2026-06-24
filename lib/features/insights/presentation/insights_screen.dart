import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'Insights',
      description: 'Review patterns and summaries when analytics arrive.',
      icon: Icons.insights_outlined,
    );
  }
}
