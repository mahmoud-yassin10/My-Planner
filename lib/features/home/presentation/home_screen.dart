import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'Home',
      description: 'A calm starting point for today and upcoming priorities.',
      icon: Icons.home_outlined,
    );
  }
}
