import 'planner_models.dart';

abstract interface class PlannerRepository {
  Future<PlannerSnapshot> current();
  Stream<PlannerSnapshot> watchPlanner();

  Future<PlannerEvent> createEvent(PlannerEventDraft draft);
  Future<PlannerEvent> updateEvent(String id, PlannerEventDraft draft);
  Future<void> archiveEvent(String id);
  Future<void> restoreEvent(String id);
  Future<void> deleteEvent(String id);

  Future<TimeBlock> createTimeBlock(TimeBlockDraft draft);
  Future<TimeBlock> updateTimeBlock(String id, TimeBlockDraft draft);
  Future<void> archiveTimeBlock(String id);
  Future<void> restoreTimeBlock(String id);
  Future<void> deleteTimeBlock(String id);

  Future<FocusSession> createFocusSession(FocusSessionDraft draft);
  Future<FocusSession> updateFocusSession(String id, FocusSessionDraft draft);
  Future<void> archiveFocusSession(String id);
  Future<void> restoreFocusSession(String id);
  Future<void> deleteFocusSession(String id);
}
