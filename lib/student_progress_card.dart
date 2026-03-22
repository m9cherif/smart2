import 'package:flutter/material.dart';

import 'package:smart_student_ai/app_strings.dart';
import 'package:smart_student_ai/database_service.dart';

class StudentProgressCard extends StatefulWidget {
  const StudentProgressCard({
    super.key,
    required this.progress,
    required this.strings,
    this.title,
    this.subtitle,
  });

  final StudentProgress progress;
  final AppStrings strings;
  final String? title;
  final String? subtitle;

  @override
  State<StudentProgressCard> createState() => _StudentProgressCardState();
}

class _StudentProgressCardState extends State<StudentProgressCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.progress.levelProgress).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );
    _progressController.forward();
  }

  @override
  void didUpdateWidget(StudentProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress.levelProgress != widget.progress.levelProgress) {
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.progress.levelProgress,
          ).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeOutCubic,
            ),
          );
      _progressController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.title != null) ...<Widget>[
              Text(widget.title!, style: theme.textTheme.titleLarge),
              if (widget.subtitle != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 18),
            ],
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.strings.progressLevelLabel(widget.progress.level),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.strings.progressXpLabel(widget.progress.xp),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (BuildContext context, Widget? child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              widget.strings.progressNextLevelLabel(
                widget.progress.xpIntoCurrentLevel,
                widget.progress.xpTargetForNextLevel,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
