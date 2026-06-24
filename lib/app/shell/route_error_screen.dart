import 'package:flutter/material.dart';

import '../../core/widgets/foundation_states.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FoundationErrorState(
        title: 'Route unavailable',
        message: 'This destination is not available in the app foundation yet.',
      ),
    );
  }
}
