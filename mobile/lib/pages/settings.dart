import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/settings/app_version_tile.dart';
import '../components/settings/theme_select_tile.dart';
import '../components/settings/whoami.dart';
import '../i18n/strings.g.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.title)),
      body: ListView(
        children: [
          // User Profile Section
          Whoami(),

          const Divider(),

          // Preferences Section
          _buildPreferencesSection(context, ref),

          const Divider(),

          // App Info Section
          _buildAppInfoSection(context),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            t.settings.preferences,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Theme Selection
        const ThemeSelectTile(),
        ListTile(
          leading: const Icon(Icons.label),
          title: Text(t.settings.tag),
          onTap: () {
            context.push("/tags");
          },
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            t.settings.about,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // App Version
        const AppVersionTile(),
        // Help & Support
        ListTile(
          leading: const Icon(Icons.help),
          title: Text(t.settings.helpSupport),
          onTap: () {
            // TODO: Implement help link
            debugPrint('Navigate to help page');
          },
        ),
      ],
    );
  }
}
