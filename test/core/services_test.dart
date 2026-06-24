import 'package:flutter_test/flutter_test.dart';
import 'package:momentum_os/core/database/persistence_conventions.dart';
import 'package:momentum_os/core/services/id_service.dart';
import 'package:momentum_os/core/services/utc_clock.dart';

void main() {
  test('UUID service creates valid v4 identifiers', () {
    final id = const UuidV4IdService().newId();

    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test('fixed ID service supports deterministic tests', () {
    final service = FixedIdService(['first-id', 'second-id']);

    expect(service.newId(), 'first-id');
    expect(service.newId(), 'second-id');
  });

  test('UTC clocks return UTC timestamps', () {
    final localValue = DateTime(2026, 6, 24, 12);
    final fixedClock = FixedUtcClock(localValue);

    expect(const SystemUtcClock().now().isUtc, isTrue);
    expect(fixedClock.now().isUtc, isTrue);
  });

  test('persistence convention normalizes timestamps to UTC', () {
    final localValue = DateTime(2026, 6, 24, 12);

    expect(PersistenceConventions.normalizeUtc(localValue).isUtc, isTrue);
  });
}
