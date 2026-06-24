import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

abstract interface class IdService {
  String newId();
}

class UuidV4IdService implements IdService {
  const UuidV4IdService({Uuid uuid = const Uuid()}) : this._(uuid);

  const UuidV4IdService._(this._uuid);

  final Uuid _uuid;

  @override
  String newId() => _uuid.v4();
}

class FixedIdService implements IdService {
  FixedIdService(this._ids);

  final List<String> _ids;
  int _index = 0;

  @override
  String newId() {
    if (_index >= _ids.length) {
      throw StateError('No deterministic IDs remain.');
    }

    return _ids[_index++];
  }
}

final idServiceProvider = Provider<IdService>((ref) {
  return const UuidV4IdService();
});
