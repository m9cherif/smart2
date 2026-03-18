import 'package:flutter/material.dart';

import 'package:smart_student_ai/app_controller.dart';
import 'package:smart_student_ai/app_strings.dart';
import 'package:smart_student_ai/database_service.dart';

class AppCustomizationPanel extends StatelessWidget {
  const AppCustomizationPanel({super.key, this.showIntro = false});

  final bool showIntro;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showIntro) ...<Widget>[
          Text(
            strings.customizeWorkspaceTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            strings.customizeWorkspaceSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
        ],
        Text(strings.themeSectionTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppThemeSpec.values
              .map(
                (spec) => _ThemePreviewCard(
                  spec: spec,
                  label: strings.themeName(spec.option),
                  selected: controller.themeOption == spec.option,
                  onTap: () => controller.updateTheme(spec.option),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 18),        // brightness toggle
        Text(strings.brightnessSectionTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Text(strings.brightnessLightLabel, style: theme.textTheme.bodyMedium),
            const SizedBox(width: 8),
            SizedBox(
              width: 140,
              child: Slider(
                value: controller.brightnessMode == AppBrightnessMode.dark ? 1 : 0,
                min: 0,
                max: 1,
                divisions: 1,
                onChanged: (value) {
                  final mode = value < 0.5
                      ? AppBrightnessMode.light
                      : AppBrightnessMode.dark;
                  controller.updateBrightnessMode(mode);
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(strings.brightnessDarkLabel, style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 18),
        Text(strings.languageSectionTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppLanguage.values
              .map(
                (language) => ChoiceChip(
                  label: Text(strings.languageName(language)),
                  selected: controller.language == language,
                  onSelected: (_) => controller.updateLanguage(language),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 24),
        // reset database button
        OutlinedButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text(strings.settingsResetDataConfirmTitle),
                  content: Text(strings.settingsResetDataConfirmMessage),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(MaterialLocalizations.of(ctx)
                          .cancelButtonLabel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(strings.settingsResetDataConfirmAction),
                    ),
                  ],
                );
              },
            );
            if (confirmed == true) {
              await DatabaseService.instance.formatDatabase();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.settingsResetData)),
                );
              }
            }
          },
          icon: Icon(Icons.delete_forever,
              color: theme.colorScheme.error),
          label: Text(strings.settingsResetData),
          style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error),
        ),
      ],
    );
  }
}

class AppSettingsButton extends StatelessWidget {
  const AppSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return IconButton(
      onPressed: () => showAppCustomizationSheet(context),
      tooltip: strings.settingsTooltip,
      icon: const Icon(Icons.tune_rounded),
    );
  }
}

Future<void> showAppCustomizationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: const AppCustomizationPanel(showIntro: true),
        ),
      );
    },
  );
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.spec,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppThemeSpec spec;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = spec.heroForeground;

    return SizedBox(
      width: 154,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: spec.heroGradient,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected
                    ? foreground.withValues(alpha: 0.95)
                    : foreground.withValues(alpha: 0.34),
                width: selected ? 2.2 : 1.2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: spec.primary.withValues(alpha: selected ? 0.28 : 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.palette_outlined, color: foreground, size: 20),
                      const Spacer(),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: foreground,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: foreground),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      _ColorDot(color: spec.primary, borderColor: foreground),
                      const SizedBox(width: 8),
                      _ColorDot(color: spec.secondary, borderColor: foreground),
                      const SizedBox(width: 8),
                      _ColorDot(color: spec.tertiary, borderColor: foreground),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.borderColor});

  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
    );
  }
}
