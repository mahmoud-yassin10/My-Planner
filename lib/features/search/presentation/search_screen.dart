import 'package:flutter/material.dart';

import '../../../app/shell/destination_placeholder.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DestinationPlaceholder(
      title: 'Search',
      description: 'Global search will be connected after app data exists.',
      icon: Icons.search,
    );
  }
}
