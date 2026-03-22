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

    // Build theme preview cards for preset themes
    final presetCards = AppThemeSpec.values
        .map(
          (spec) => _ThemePreviewCard(
            spec: spec,
            label: strings.themeName(spec.option),
            selected: controller.themeOption == spec.option,
            onTap: () => controller.updateTheme(spec.option),
          ),
        )
        .toList(growable: false);

    // Build the custom theme card if custom is selected
    final customSpec = AppThemeSpec.fromSeedColor(controller.customColor);

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
          children: [
            ...presetCards,
            // Custom theme card
            _ThemePreviewCard(
              spec: customSpec,
              label: strings.themeName(AppThemeOption.custom),
              selected: controller.themeOption == AppThemeOption.custom,
              onTap: () => controller.updateCustomColor(controller.customColor),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // ── Custom Color Picker Section ──
        Text(strings.customColorSectionTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          strings.customColorPickerHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        _ColorPickerGrid(
          selectedColor: controller.customColor,
          onColorSelected: (color) => controller.updateCustomColor(color),
        ),
        const SizedBox(height: 16),
        _HueSliderPicker(
          selectedColor: controller.customColor,
          onColorChanged: (color) => controller.updateCustomColor(color),
        ),
        const SizedBox(height: 24),
        // brightness toggle
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

// ── Preset Color Grid ──────────────────────────────────────────────────────────

class _ColorPickerGrid extends StatelessWidget {
  const _ColorPickerGrid({
    required this.selectedColor,
    required this.onColorSelected,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  static const List<Color> _presetColors = <Color>[
    Color(0xFF6750A4), // Purple
    Color(0xFF9C27B0), // Deep Purple
    Color(0xFFE91E63), // Pink
    Color(0xFFF44336), // Red
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFF9800), // Orange
    Color(0xFFFFC107), // Amber
    Color(0xFF8BC34A), // Light Green
    Color(0xFF4CAF50), // Green
    Color(0xFF009688), // Teal
    Color(0xFF00BCD4), // Cyan
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF2196F3), // Blue
    Color(0xFF3F51B5), // Indigo
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
    Color(0xFF424242), // Dark Grey
    Color(0xFF37474F), // Charcoal
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _presetColors.map((color) {
        final isSelected = _isColorClose(color, selectedColor);
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: <BoxShadow>[
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(growable: false),
    );
  }

  bool _isColorClose(Color a, Color b) {
    return (a.red - b.red).abs() < 15 &&
        (a.green - b.green).abs() < 15 &&
        (a.blue - b.blue).abs() < 15;
  }
}

// ── Hue Slider ─────────────────────────────────────────────────────────────────

class _HueSliderPicker extends StatelessWidget {
  const _HueSliderPicker({
    required this.selectedColor,
    required this.onColorChanged,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(selectedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hue slider
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: List<Color>.generate(
                360 ~/ 10,
                (i) => HSLColor.fromAHSL(1, i * 10.0, 0.7, 0.45).toColor(),
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: selectedColor.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 40,
              trackShape: const _FullWidthTrackShape(),
              thumbShape: const _CircleThumbShape(radius: 16),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: hsl.hue,
              min: 0,
              max: 359,
              onChanged: (hue) {
                final newColor = HSLColor.fromAHSL(
                  1,
                  hue,
                  hsl.saturation.clamp(0.4, 0.85),
                  hsl.lightness.clamp(0.3, 0.5),
                ).toColor();
                onColorChanged(newColor);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Live preview of current custom color
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Custom slider shapes ────────────────────────────────────────────────────────

class _FullWidthTrackShape extends RoundedRectSliderTrackShape {
  const _FullWidthTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 40;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(offset.dx, trackTop, parentBox.size.width, trackHeight);
  }
}

class _CircleThumbShape extends SliderComponentShape {
  const _CircleThumbShape({required this.radius});

  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // Outer shadow
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // White circle
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    // Inner color dot
    final hue = value * 359;
    final dotColor = HSLColor.fromAHSL(1, hue, 0.7, 0.45).toColor();
    canvas.drawCircle(center, radius - 4, Paint()..color = dotColor);
  }
}

// ── Existing widgets ────────────────────────────────────────────────────────────

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
