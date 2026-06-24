enum AppThemePreference { system, light, dark }

enum TimeFormatPreference { system, twelveHour, twentyFourHour }

class AppSettingsPreferences {
  const AppSettingsPreferences({
    this.themeMode = AppThemePreference.system,
    this.accentColorValue,
    this.localeTag,
    this.firstDayOfWeek = DateTime.monday,
    this.timeFormat = TimeFormatPreference.system,
  });

  final AppThemePreference themeMode;
  final int? accentColorValue;
  final String? localeTag;
  final int firstDayOfWeek;
  final TimeFormatPreference timeFormat;

  static const defaults = AppSettingsPreferences();

  AppSettingsPreferences copyWith({
    AppThemePreference? themeMode,
    Object? accentColorValue = _unchanged,
    Object? localeTag = _unchanged,
    int? firstDayOfWeek,
    TimeFormatPreference? timeFormat,
  }) {
    return AppSettingsPreferences(
      themeMode: themeMode ?? this.themeMode,
      accentColorValue: identical(accentColorValue, _unchanged)
          ? this.accentColorValue
          : accentColorValue as int?,
      localeTag: identical(localeTag, _unchanged)
          ? this.localeTag
          : localeTag as String?,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      timeFormat: timeFormat ?? this.timeFormat,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'themeMode': themeMode.name,
      'accentColorValue': accentColorValue,
      'localeTag': localeTag,
      'firstDayOfWeek': firstDayOfWeek,
      'timeFormat': timeFormat.name,
    };
  }

  factory AppSettingsPreferences.fromJson(Map<String, Object?> json) {
    return AppSettingsPreferences(
      themeMode: AppThemePreference.values.byName(
        json['themeMode'] as String? ?? AppThemePreference.system.name,
      ),
      accentColorValue: json['accentColorValue'] as int?,
      localeTag: json['localeTag'] as String?,
      firstDayOfWeek: json['firstDayOfWeek'] as int? ?? DateTime.monday,
      timeFormat: TimeFormatPreference.values.byName(
        json['timeFormat'] as String? ?? TimeFormatPreference.system.name,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettingsPreferences &&
        other.themeMode == themeMode &&
        other.accentColorValue == accentColorValue &&
        other.localeTag == localeTag &&
        other.firstDayOfWeek == firstDayOfWeek &&
        other.timeFormat == timeFormat;
  }

  @override
  int get hashCode => Object.hash(
    themeMode,
    accentColorValue,
    localeTag,
    firstDayOfWeek,
    timeFormat,
  );
}

const _unchanged = Object();

abstract interface class SettingsRepository {
  Future<AppSettingsPreferences> current();

  Stream<AppSettingsPreferences> watch();

  Future<void> update(AppSettingsPreferences preferences);

  Future<void> reset();
}
