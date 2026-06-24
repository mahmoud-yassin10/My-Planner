/// Phase 3 persistent entities must generate UUID v4 string identifiers before
/// inserts, store timestamps in UTC, keep `createdAt` immutable, update
/// `updatedAt` on meaningful writes, and document archive/delete behavior per
/// entity.
abstract final class PersistenceConventions {
  static const idColumn = 'id';
  static const createdAtColumn = 'createdAt';
  static const updatedAtColumn = 'updatedAt';
  static const archivedAtColumn = 'archivedAt';

  static DateTime normalizeUtc(DateTime value) => value.toUtc();
}
