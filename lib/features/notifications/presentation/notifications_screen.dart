import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'Notifications',
      description: 'Notification inbox behavior will be added later.',
      icon: Icons.notifications_outlined,
    );
  }
}
