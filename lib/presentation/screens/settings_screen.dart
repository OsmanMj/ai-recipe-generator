import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_provider.dart';
import '../../core/constants/app_constants.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark theme"),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (val) {
              ref.read(themeModeNotifierProvider.notifier).toggle();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text("Clear Favorites",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              // Logic to clear favorites
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Clear Favorites?"),
                  content: const Text(
                      "Are you sure you want to delete all your saved recipes?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref.read(favoritesProvider.notifier).clearAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Favorites cleared!")),
                          );
                        }
                      },
                      child: const Text("Clear",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("How to use the app"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const OnboardingScreen(isFromSettings: true),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About App"),
            subtitle: const Text("Version ${AppConstants.appVersion}"),
          ),
        ],
      ),
    );
  }
}
