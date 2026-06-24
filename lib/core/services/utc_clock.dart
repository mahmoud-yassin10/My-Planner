import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class UtcClock {
  DateTime now();
}

class SystemUtcClock implements UtcClock {
  const SystemUtcClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

class FixedUtcClock implements UtcClock {
  const FixedUtcClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value.toUtc();
}

final utcClockProvider = Provider<UtcClock>((ref) {
  return const SystemUtcClock();
});
