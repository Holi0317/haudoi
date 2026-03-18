import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'app_router.dart';
import 'components/events/archive_action_worker.dart';
import 'components/events/sync_worker.dart';
import 'i18n/strings.g.dart';
import 'providers/bindings/shared_preferences.dart';
import 'providers/logger_observer.dart';
import 'repositories/retry.dart';

void main() {
  Logger.root.onRecord.listen((record) {
    final sb = StringBuffer()
      ..writeln(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
      );
    if (record.error != null) {
      sb.writeln('Error (${record.error.runtimeType}): ${record.error}');
    }
    if (record.stackTrace != null) {
      sb.writeln('StackTrace:\n${record.stackTrace}');
    }

    // ignore: avoid_print
    print(sb.toString());
  });

  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  runApp(
    ProviderScope(
      retry: retryStrategy,
      observers: [const LoggerObserver()],
      child: TranslationProvider(
        child: ArchiveActionWorkerWidget(
          child: SyncWorkerWidget(
            child: Consumer(
              builder: (context, ref, child) {
                final themeAsync = ref.watch(
                  preferenceProvider(SharedPreferenceKey.theme),
                );
                final themeMode = switch (themeAsync.value) {
                  'light' => ThemeMode.light,
                  'dark' => ThemeMode.dark,
                  'system' || null || _ => ThemeMode.system,
                };

                return MaterialApp.router(
                  locale: TranslationProvider.of(context).flutterLocale,
                  // use provider
                  supportedLocales: AppLocaleUtils.supportedLocales,
                  localizationsDelegates: GlobalMaterialLocalizations.delegates,
                  routerConfig: router,
                  // FIXME: Replace with a proper title
                  title: 'Flutter Demo',
                  themeMode: themeMode,
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.deepPurple,
                    ),
                  ),
                  darkTheme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.deepPurple,
                      brightness: Brightness.dark,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
