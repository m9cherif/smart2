import 'package:flutter/material.dart';

import 'package:smart_student_ai/app_controller.dart';
import 'package:smart_student_ai/app_strings.dart';
import 'package:smart_student_ai/database_service.dart';
import 'package:smart_student_ai/app_customization_panel.dart';
import 'package:smart_student_ai/notification_service.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _controller = TextEditingController();

  List<PlannerTask> _tasks = <PlannerTask>[];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _selectedPriority = 'Medium';
  DateTime? _selectedDueDate;
  int? _selectedReminderMinutes;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final taskMaps = await _databaseService.getTasks();
      if (!mounted) {
        return;
      }

      setState(() {
        _tasks = taskMaps.map(PlannerTask.fromMap).toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _plannerErrorDetails(error);
      });
    }
  }

  Future<void> _addTask() async {
    final strings = AppStrings.of(context);
    final title = _controller.text.trim();
    if (title.isEmpty || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final id = await _databaseService.insertTask(
        title: title,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        reminderMinutes: _selectedReminderMinutes,
      );

      if (_selectedDueDate != null && _selectedReminderMinutes != null) {
        await NotificationService.instance.scheduleTaskReminder(
          id: id,
          title: title,
          dueDate: _selectedDueDate!,
          reminderMinutes: _selectedReminderMinutes!,
        );
      }

      _controller.clear();
      _selectedDueDate = null;
      _selectedPriority = 'Medium';
      _selectedReminderMinutes = null;
      await _loadTasks();
      TaskEvents.instance.refresh(); // Notify other screens
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.plannerTaskAddedMessage())),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.plannerErrorMessage(_plannerErrorDetails(error)),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _toggleTask(PlannerTask task, bool completed) async {
    try {
      await _databaseService.updateTaskStatus(task.id, completed);
      await _loadTasks();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.of(
              context,
            ).plannerErrorMessage(_plannerErrorDetails(error)),
          ),
        ),
      );
    }
  }

  Future<void> _deleteTask(PlannerTask task) async {
    final strings = AppStrings.of(context);
    try {
      await _databaseService.deleteTask(task.id);
      await NotificationService.instance.cancelReminder(task.id);
      await _loadTasks();
      TaskEvents.instance.refresh(); // Notify other screens
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.plannerTaskRemovedMessage(task.title))),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.plannerErrorMessage(_plannerErrorDetails(error)),
          ),
        ),
      );
    }
  }

  Future<void> _clearCompleted() async {
    final strings = AppStrings.of(context);
    try {
      final removedCount = await _databaseService.deleteCompletedTasks();
      await _loadTasks();
      TaskEvents.instance.refresh(); // Notify other screens
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.plannerClearedCompletedMessage(removedCount)),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.plannerErrorMessage(_plannerErrorDetails(error)),
          ),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      final current = _selectedDueDate ?? now;
      _selectedDueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        current.hour,
        current.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? now),
    );

    if (pickedTime == null || !mounted) {
      return;
    }

    setState(() {
      final current = _selectedDueDate ?? now;
      _selectedDueDate = DateTime(
        current.year,
        current.month,
        current.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((task) => task.completed).length;
    final openTasks = totalTasks - completedTasks;
    final now = DateTime.now();
    final dueSoon = _tasks
        .where(
          (task) =>
              !task.completed &&
              task.dueDate != null &&
              !task.dueDate!.isBefore(DateTime(now.year, now.month, now.day)) &&
              task.dueDate!
                      .difference(DateTime(now.year, now.month, now.day))
                      .inDays <=
                  2,
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.plannerTitle),
        actions: <Widget>[
          const AppSettingsButton(),
          IconButton(
            onPressed: completedTasks == 0 || _isLoading
                ? null
                : () => _clearCompleted(),
            tooltip: strings.plannerClearCompletedTooltip,
            icon: const Icon(Icons.playlist_remove_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      strings.plannerCaptureTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.plannerCaptureSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTask(),
                      decoration: InputDecoration(
                        labelText: strings.plannerTaskTitleLabel,
                        hintText: strings.plannerTaskTitleHint,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey<String>(_selectedPriority),
                            initialValue: _selectedPriority,
                            decoration: InputDecoration(
                              labelText: strings.plannerPriorityLabel,
                            ),
                            items: const <String>['High', 'Medium', 'Low']
                                .map(
                                  (priority) => DropdownMenuItem<String>(
                                    value: priority,
                                    child: Text(
                                      strings.priorityLabel(priority),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _selectedPriority = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today_rounded),
                            label: Text(
                              _selectedDueDate == null
                                  ? strings.plannerNoDueDate
                                  : MaterialLocalizations.of(context).formatMediumDate(_selectedDueDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time_rounded),
                            label: Text(
                              _selectedDueDate == null
                                  ? strings.plannerNoTime
                                  : TimeOfDay.fromDateTime(_selectedDueDate!).format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      initialValue: _selectedReminderMinutes,
                      decoration: InputDecoration(
                        labelText: strings.plannerReminderLabel,
                      ),
                      items: [
                        null,
                        60,
                        120,
                        180,
                        240,
                        480,
                        1440,
                        2880,
                        4320
                      ].map((minutes) {
                        return DropdownMenuItem<int?>(
                          value: minutes,
                          child: Text(
                            strings.reminderIntervalLabel(minutes),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedReminderMinutes = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _addTask,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add_task_rounded),
                        label: Text(
                          _isSaving
                              ? strings.plannerSaving
                              : strings.plannerAddTask,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final testTime = now.add(const Duration(minutes: 1));
                        final success = await NotificationService.instance.scheduleTaskReminder(
                          id: 9999,
                          title: "Test Reminder",
                          dueDate: testTime.add(const Duration(seconds: 10)), // Just after
                          reminderMinutes: 0, // Remind exactly at testTime
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success 
                                ? 'Test reminder scheduled for 1 minute from now.' 
                                : 'Failed to schedule test reminder.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.bug_report_rounded, size: 16),
                      label: const Text('Test Reminder (1 min)'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: _PlannerStatCard(
                    label: strings.plannerOpen,
                    value: '$openTasks',
                    accent: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PlannerStatCard(
                    label: strings.plannerDone,
                    value: '$completedTasks',
                    accent: const Color(0xFF2A7F62),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PlannerStatCard(
                    label: strings.plannerDueSoon,
                    value: '$dueSoon',
                    accent: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              strings.plannerTaskBoard,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              strings.plannerTaskBoardSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.storage_rounded,
                        size: 44,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        strings.plannerErrorTitle,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.plannerErrorMessage(_errorMessage!),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadTasks,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(strings.retryAction),
                      ),
                    ],
                  ),
                ),
              )
            else if (_tasks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.checklist_rtl_rounded,
                        size: 44,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        strings.plannerEmptyTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.plannerEmptySubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (value) => _toggleTask(task, value ?? false),
                      ),
                      title: Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.completed
                              ? theme.colorScheme.onSurfaceVariant
                              : null,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            _TaskChip(
                              label: strings.priorityLabel(task.priority),
                              accent: _priorityColor(task.priority),
                            ),
                            _TaskChip(
                              label: task.dueDate == null
                                  ? strings.plannerNoDeadline
                                  : strings.plannerDeadlineLabel(
                                      _formatDate(context, task.dueDate!),
                                    ),
                              accent: theme.colorScheme.primary,
                            ),
                            _TaskChip(
                              label: strings.plannerAddedLabel(
                                _formatDate(context, task.createdAt),
                              ),
                              accent: const Color(0xFF596A7B),
                            ),
                          ],
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          if (task.reminderMinutes != null && !task.completed)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Icon(
                                Icons.notifications_active_rounded,
                                size: 20,
                                color: Color(0xFFE38B29),
                              ),
                            ),
                          IconButton(
                            onPressed: () => _deleteTask(task),
                            tooltip: strings.plannerDeleteTaskTooltip,
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFC63D2F);
      case 'Low':
        return const Color(0xFF2A7F62);
      case 'Medium':
      default:
        return const Color(0xFFE38B29);
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final dateStr = MaterialLocalizations.of(context).formatMediumDate(date);
    final timeStr = TimeOfDay.fromDateTime(date).format(context);
    return '$dateStr $timeStr';
  }

  String _plannerErrorDetails(Object error) {
    if (error is UnsupportedError) {
      return error.message?.toString() ?? error.toString();
    }

    return error.toString();
  }
}

class _PlannerStatCard extends StatelessWidget {
  const _PlannerStatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: accent, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class PlannerTask {
  PlannerTask({
    required this.id,
    required this.title,
    required this.priority,
    required this.completed,
    required this.createdAt,
    required this.dueDate,
    required this.reminderMinutes,
  });

  factory PlannerTask.fromMap(Map<String, dynamic> map) {
    return PlannerTask(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      priority: map['priority'] as String? ?? 'Medium',
      completed: (map['completed'] as int? ?? 0) == 1,
      createdAt:
          DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? ''),
      reminderMinutes: map['reminderMinutes'] as int?,
    );
  }

  final int id;
  final String title;
  final String priority;
  final bool completed;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int? reminderMinutes;
}
