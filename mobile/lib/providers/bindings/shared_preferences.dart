import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences.g.dart';

/// Underlying SharedPreferences singleton.
@Riverpod(keepAlive: true)
Future<SharedPreferences> _sharedPreferences(Ref ref) async {
  return SharedPreferences.getInstance();
}

/// Keys for SharedPreferences.
///
/// Currently only supports String values.
enum SharedPreferenceKey {
  apiUrl('api_url', ''),
  apiToken('api_token', ''),
  theme('theme', 'system'); // light, dark, system

  final String key;
  final String defaultValue;

  const SharedPreferenceKey(this.key, this.defaultValue);
}

@Riverpod(keepAlive: true)
class Preference extends _$Preference {
  @override
  Future<String> build(SharedPreferenceKey key) async {
    final prefs = await ref.watch(_sharedPreferencesProvider.future);
    return prefs.getString(key.key) ?? key.defaultValue;
  }

  Future<void> set(String value) async {
    final prefs = await ref.read(_sharedPreferencesProvider.future);
    await prefs.setString(key.key, value);
    // Update the state to notify listeners
    state = AsyncValue.data(value);
  }

  Future<void> reset() async {
    final prefs = await ref.read(_sharedPreferencesProvider.future);
    await prefs.setString(key.key, key.defaultValue);
    // Update the state to notify listeners
    state = AsyncValue.data(key.defaultValue);
  }
}

@Riverpod(keepAlive: true)
class RecentServers extends _$RecentServers {
  static final _key = "recent_servers";

  @override
  Future<List<String>> build() async {
    final prefs = await ref.watch(_sharedPreferencesProvider.future);
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String value) async {
    final prefs = await ref.read(_sharedPreferencesProvider.future);

    final current = (prefs.getStringList(_key) ?? [])..add(value);

    final next = current.toSet().toList();

    await prefs.setStringList(_key, next);

    // Update the state to notify listeners
    state = AsyncValue.data(next);
  }

  Future<void> remove(String value) async {
    final prefs = await ref.read(_sharedPreferencesProvider.future);
    final current = (prefs.getStringList(_key) ?? []).toList();

    current.remove(value);

    await prefs.setStringList(_key, current);

    // Update the state to notify listeners
    state = AsyncValue.data(current);
  }

  Future<void> reset() async {
    final prefs = await ref.read(_sharedPreferencesProvider.future);
    await prefs.setStringList(_key, []);

    // Update the state to notify listeners
    state = const AsyncValue.data([]);
  }
}
