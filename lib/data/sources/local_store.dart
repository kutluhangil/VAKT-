import 'package:hive_flutter/hive_flutter.dart';

/// Thin Hive wrapper. All on-device persistence goes through here:
/// user settings (locale, theme, onboarding, notifications) and favorites.
/// No personal data leaves the device (blueprint §14).
class LocalStore {
  LocalStore._();
  static final LocalStore instance = LocalStore._();

  static const _settingsBox = 'settings';
  static const _favoritesBox = 'favorites';

  // Setting keys
  static const kLocale = 'locale'; // 'tr' | 'en' | null (system)
  static const kThemeMode = 'themeMode'; // 'light' | 'dark' | 'system'
  static const kOnboardingDone = 'onboardingDone'; // bool
  static const kNotificationsEnabled = 'notificationsEnabled'; // bool
  static const kNotificationHour = 'notificationHour'; // int
  static const kNotificationMinute = 'notificationMinute'; // int

  late Box _settings;
  late Box _favorites;

  Future<void> init() async {
    await Hive.initFlutter();
    await _openBoxes();
  }

  /// Test-only: initialize Hive against a real directory (no path_provider).
  Future<void> initWithPath(String path) async {
    Hive.init(path);
    await _openBoxes();
  }

  Future<void> _openBoxes() async {
    _settings = await Hive.openBox(_settingsBox);
    _favorites = await Hive.openBox(_favoritesBox);
  }

  // Generic settings access
  T? get<T>(String key, {T? defaultValue}) =>
      _settings.get(key, defaultValue: defaultValue) as T?;

  Future<void> set<T>(String key, T value) => _settings.put(key, value);

  Future<void> remove(String key) => _settings.delete(key);

  // Favorites (tip ids). Used from Phase 3 onward.
  List<String> get favoriteIds =>
      _favorites.keys.map((e) => e.toString()).toList();

  bool isFavorite(String id) => _favorites.containsKey(id);

  Future<void> addFavorite(String id) =>
      _favorites.put(id, DateTime.now().toIso8601String());

  Future<void> removeFavorite(String id) => _favorites.delete(id);
}
