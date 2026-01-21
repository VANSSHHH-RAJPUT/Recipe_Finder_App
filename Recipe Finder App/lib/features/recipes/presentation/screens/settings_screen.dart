import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../controllers/recipe_list_controller.dart';
import '../state/recipe_list_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final themeNotifier = ref.read(themeControllerProvider.notifier);
    final recipeState = ref.watch(recipeListControllerProvider);
    final recipeController = ref.read(recipeListControllerProvider.notifier);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SettingsHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personalize your experience',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 20),
                        _ThemePreferenceCard(
                          title: 'Theme',
                          options: const [
                            ('System', ThemePreference.system),
                            ('Light', ThemePreference.light),
                            ('Dark', ThemePreference.dark),
                          ],
                          selected: themeMode,
                          onSelected: themeNotifier.setPreference,
                        ),
                        const SizedBox(height: 20),
                        _ViewModePreferenceCard(
                          currentMode: recipeState.viewMode,
                          onSelected: recipeController.setViewMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.settingsTab,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Control global preferences like theme and default view.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePreferenceCard extends StatelessWidget {
  const _ThemePreferenceCard({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<(String, ThemePreference)> options;
  final ThemeMode selected;
  final ValueChanged<ThemePreference> onSelected;

  @override
  Widget build(BuildContext context) {
    ThemePreference? currentPreference;
    switch (selected) {
      case ThemeMode.system:
        currentPreference = ThemePreference.system;
        break;
      case ThemeMode.light:
        currentPreference = ThemePreference.light;
        break;
      case ThemeMode.dark:
        currentPreference = ThemePreference.dark;
        break;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options
                .map(
                  (option) => ChoiceChip(
                    label: Text(option.$1),
                    selected: currentPreference == option.$2,
                    onSelected: (_) => onSelected(option.$2),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ViewModePreferenceCard extends StatelessWidget {
  const _ViewModePreferenceCard({
    required this.currentMode,
    required this.onSelected,
  });

  final RecipeViewMode currentMode;
  final ValueChanged<RecipeViewMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default recipe view',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how recipes appear across the app.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: RecipeViewMode.values
                .map(
                  (mode) => ChoiceChip(
                    label: Text(mode == RecipeViewMode.grid ? 'Grid' : 'List'),
                    selected: currentMode == mode,
                    onSelected: (_) => onSelected(mode),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
