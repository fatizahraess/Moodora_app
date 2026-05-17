// Task management screen with filters, sorting, task form, and deletion safeguards.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/focus_coach_provider.dart';
import '../providers/focus_map_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/date_formatter.dart';
import '../utils/app_gradients.dart';
import '../widgets/common_gradient_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import '../theme/app_theme.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: showAppBar ? AppBar(title: const Text('Tasks')) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<PremiumGradientTheme>()?.background,
        ),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
          final error = taskProvider.errorMessage;
          if (error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              context.read<TaskProvider>().clearError();
            });
          }

          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (!showAppBar)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: _PageTitle(
                    title: 'Tasks',
                    subtitle: 'Plan your next tomato sessions',
                  ),
                ),
              _TaskControls(provider: taskProvider),
              Expanded(
                child: taskProvider.filteredTasks.isEmpty
                    ? EmptyState(
                        icon: Icons.checklist_outlined,
                        title: 'No tasks found',
                        description:
                            'Adjust filters or create a new task to start planning.',
                        actionLabel: 'New task',
                        onAction: () => _openTaskForm(context),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: taskProvider.filteredTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = taskProvider.filteredTasks[index];
                          return Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(context, task),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppConstants.dangerColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: TaskCard(
                              task: task,
                              onToggleCompleted: () async {
                                await context
                                    .read<TaskProvider>()
                                    .toggleTaskCompletion(task);
                                if (context.mounted) {
                                  context.read<StatsProvider>().loadStats();
                                  context.read<FocusCoachProvider>().loadCoach();
                                  context.read<FocusMapProvider>().loadFocusMap();
                                  _showSnackBar(context, 'Task updated');
                                }
                              },
                              onEdit: () => _openTaskForm(context, task: task),
                              onDelete: () => _deleteTask(context, task),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
    );
  }

  Future<void> _openTaskForm(BuildContext context, {Task? task}) async {
    final result = await Navigator.of(context).push<_TaskFormResult>(
      MaterialPageRoute(builder: (_) => _TaskFormPage(task: task)),
    );
    if (result == null || !context.mounted) {
      return;
    }

    if (task == null) {
      await context.read<TaskProvider>().addTask(
            title: result.title,
            description: result.description,
            priority: result.priority,
            dueDate: result.dueDate,
            estimatedPomodoros: result.estimatedPomodoros,
          );
      if (context.mounted) {
        _showSnackBar(context, 'Task added');
      }
    } else {
      await context.read<TaskProvider>().updateTask(
            task.copyWith(
              title: result.title,
              description: result.description,
              priority: result.priority,
              dueDate: result.dueDate,
              estimatedPomodoros: result.estimatedPomodoros,
              clearDueDate: result.dueDate == null,
            ),
          );
      if (context.mounted) {
        _showSnackBar(context, 'Task updated');
      }
    }
    if (context.mounted) {
      context.read<StatsProvider>().loadStats();
      context.read<FocusCoachProvider>().loadCoach();
      context.read<FocusMapProvider>().loadFocusMap();
    }
  }

  Future<bool> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('This will permanently delete "${task.title}".'),
        actions: [
          CommonGradientButton(
            label: 'Cancel',
            primary: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          CommonGradientButton(
            label: 'Delete',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    if (!await _confirmDelete(context, task) || !context.mounted) {
      return;
    }
    await context.read<TaskProvider>().deleteTask(task.id!);
    if (context.mounted) {
      context.read<StatsProvider>().loadStats();
      context.read<FocusCoachProvider>().loadCoach();
      context.read<FocusMapProvider>().loadFocusMap();
      _showSnackBar(context, 'Task deleted');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TaskControls extends StatelessWidget {
  const _TaskControls({required this.provider});

  final TaskProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FilterBox(
            child: DropdownButton<TaskStatusFilter>(
              value: provider.statusFilter,
              underline: const SizedBox.shrink(),
              onChanged: (value) {
                if (value != null) {
                  provider.setStatusFilter(value);
                }
              },
              items: const [
                DropdownMenuItem(value: TaskStatusFilter.all, child: Text('All')),
                DropdownMenuItem(
                  value: TaskStatusFilter.active,
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: TaskStatusFilter.completed,
                  child: Text('Completed'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _FilterBox(
            child: DropdownButton<String>(
              value: provider.priorityFilter ?? 'any',
              underline: const SizedBox.shrink(),
              onChanged: (value) {
                provider.setPriorityFilter(value == 'any' ? null : value);
              },
              items: const [
                DropdownMenuItem(value: 'any', child: Text('Any priority')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _FilterBox(
            child: DropdownButton<TaskSortOption>(
              value: provider.sortOption,
              underline: const SizedBox.shrink(),
              onChanged: (value) {
                if (value != null) {
                  provider.setSortOption(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: TaskSortOption.priority,
                  child: Text('Priority'),
                ),
                DropdownMenuItem(
                  value: TaskSortOption.created,
                  child: Text('Created'),
                ),
                DropdownMenuItem(
                  value: TaskSortOption.dueDate,
                  child: Text('Due date'),
                ),
                DropdownMenuItem(value: TaskSortOption.title, child: Text('Title')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightLine),
      ),
      child: child,
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _TaskFormPage extends StatefulWidget {
  const _TaskFormPage({this.task});

  final Task? task;

  @override
  State<_TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<_TaskFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _priority;
  late int _estimatedPomodoros;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? 'medium';
    _estimatedPomodoros = task?.estimatedPomodoros ?? 1;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(isEditing ? 'Edit task' : 'New task')),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<PremiumGradientTheme>()?.background,
        ),
        child: SafeArea(
          child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.task_alt),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a task title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: AppConstants.priorities
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  _dueDate == null
                      ? 'No due date'
                      : 'Due ${DateFormatter.readableDate(_dueDate!)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_dueDate != null)
                      IconButton(
                        tooltip: 'Clear due date',
                        onPressed: () => setState(() => _dueDate = null),
                        icon: const Icon(Icons.close),
                      ),
                    IconButton(
                      tooltip: 'Pick due date',
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Text('Estimated Pomodoros')),
                  IconButton(
                    onPressed: _estimatedPomodoros > 1
                        ? () => setState(() => _estimatedPomodoros--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    _estimatedPomodoros.toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () => setState(() => _estimatedPomodoros++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CommonGradientButton(
                onPressed: _submit,
                icon: Icons.save,
                label: isEditing ? 'Save task' : 'Add task',
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(
      _TaskFormResult(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        estimatedPomodoros: _estimatedPomodoros,
      ),
    );
  }
}

class _TaskFormResult {
  const _TaskFormResult({
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedPomodoros,
    this.dueDate,
  });

  final String title;
  final String description;
  final String priority;
  final DateTime? dueDate;
  final int estimatedPomodoros;
}
