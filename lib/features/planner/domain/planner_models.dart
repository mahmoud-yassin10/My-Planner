enum PlannerEventKind { event, meeting }

enum TimeBlockKind { focus, buffer, personal, travel }

class PlannerEvent {
  const PlannerEvent({
    required this.id,
    required this.title,
    this.description,
    required this.kind,
    required this.startsAt,
    required this.endsAt,
    required this.isAllDay,
    this.location,
    this.meetingUrl,
    this.linkedTaskId,
    this.recurrenceRule,
    this.reminderPolicy,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String? description;
  final PlannerEventKind kind;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isAllDay;
  final String? location;
  final String? meetingUrl;
  final String? linkedTaskId;
  final String? recurrenceRule;
  final String? reminderPolicy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class TimeBlock {
  const TimeBlock({
    required this.id,
    required this.title,
    required this.kind,
    required this.startsAt,
    required this.endsAt,
    this.linkedTaskId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final TimeBlockKind kind;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? linkedTaskId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

class PlannerSnapshot {
  const PlannerSnapshot({this.events = const [], this.timeBlocks = const []});

  final List<PlannerEvent> events;
  final List<TimeBlock> timeBlocks;

  bool get isEmpty => events.isEmpty && timeBlocks.isEmpty;
}

class PlannerEventDraft {
  const PlannerEventDraft({
    required this.title,
    this.description,
    this.kind = PlannerEventKind.event,
    required this.startsAt,
    required this.endsAt,
    this.isAllDay = false,
    this.location,
    this.meetingUrl,
    this.linkedTaskId,
    this.recurrenceRule,
    this.reminderPolicy,
  });

  final String title;
  final String? description;
  final PlannerEventKind kind;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isAllDay;
  final String? location;
  final String? meetingUrl;
  final String? linkedTaskId;
  final String? recurrenceRule;
  final String? reminderPolicy;
}

class TimeBlockDraft {
  const TimeBlockDraft({
    required this.title,
    this.kind = TimeBlockKind.focus,
    required this.startsAt,
    required this.endsAt,
    this.linkedTaskId,
    this.notes,
  });

  final String title;
  final TimeBlockKind kind;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? linkedTaskId;
  final String? notes;
}

class PlannerScheduleItem {
  const PlannerScheduleItem({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.startsAt,
    required this.endsAt,
  });

  final String id;
  final String title;
  final String sourceType;
  final DateTime startsAt;
  final DateTime endsAt;
}

class ScheduleConflict {
  const ScheduleConflict({required this.first, required this.second});

  final PlannerScheduleItem first;
  final PlannerScheduleItem second;
}

class FreeWindow {
  const FreeWindow({required this.startsAt, required this.endsAt});

  final DateTime startsAt;
  final DateTime endsAt;

  int get durationMinutes => endsAt.difference(startsAt).inMinutes;
}

List<PlannerScheduleItem> plannerScheduleItems(PlannerSnapshot snapshot) {
  final items = <PlannerScheduleItem>[
    for (final event in snapshot.events)
      if (!event.isArchived)
        PlannerScheduleItem(
          id: event.id,
          title: event.title,
          sourceType: event.kind.name,
          startsAt: event.startsAt,
          endsAt: event.endsAt,
        ),
    for (final block in snapshot.timeBlocks)
      if (!block.isArchived)
        PlannerScheduleItem(
          id: block.id,
          title: block.title,
          sourceType: '${block.kind.name} block',
          startsAt: block.startsAt,
          endsAt: block.endsAt,
        ),
  ];
  items.sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return items;
}

List<ScheduleConflict> detectScheduleConflicts(
  List<PlannerScheduleItem> items,
) {
  final sorted = [...items]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  final conflicts = <ScheduleConflict>[];
  for (var index = 1; index < sorted.length; index += 1) {
    final previous = sorted[index - 1];
    final current = sorted[index];
    if (current.startsAt.isBefore(previous.endsAt)) {
      conflicts.add(ScheduleConflict(first: previous, second: current));
    }
  }
  return conflicts;
}

List<FreeWindow> findFreeWindows({
  required List<PlannerScheduleItem> items,
  required DateTime startsAt,
  required DateTime endsAt,
  int minimumMinutes = 30,
}) {
  final relevant = [...items]
    ..removeWhere(
      (item) =>
          !item.endsAt.isAfter(startsAt) || !item.startsAt.isBefore(endsAt),
    )
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  final windows = <FreeWindow>[];
  var cursor = startsAt;
  for (final item in relevant) {
    if (item.startsAt.isAfter(cursor)) {
      final window = FreeWindow(startsAt: cursor, endsAt: item.startsAt);
      if (window.durationMinutes >= minimumMinutes) {
        windows.add(window);
      }
    }
    if (item.endsAt.isAfter(cursor)) {
      cursor = item.endsAt;
    }
  }
  if (endsAt.isAfter(cursor)) {
    final window = FreeWindow(startsAt: cursor, endsAt: endsAt);
    if (window.durationMinutes >= minimumMinutes) {
      windows.add(window);
    }
  }
  return windows;
}
