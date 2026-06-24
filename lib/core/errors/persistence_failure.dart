sealed class PersistenceFailure implements Exception {
  const PersistenceFailure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class PersistenceReadFailure extends PersistenceFailure {
  const PersistenceReadFailure(super.message);
}

class PersistenceWriteFailure extends PersistenceFailure {
  const PersistenceWriteFailure(super.message);
}

class PersistenceValidationFailure extends PersistenceFailure {
  const PersistenceValidationFailure(super.message);
}
