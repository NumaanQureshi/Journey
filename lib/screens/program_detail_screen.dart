import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../services/workout_service.dart';

class ProgramDetailScreen extends StatefulWidget {
  final Program program;

  const ProgramDetailScreen({
    super.key,
    required this.program,
  });

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load templates and exercises when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WorkoutProvider>();
      debugPrint('DEBUG: ProgramDetailScreen initState - loading templates and exercises');
      provider.setActiveProgram(widget.program);
      provider.loadTemplatesForActiveProgram();
      // Ensure exercises are loaded for the dialog
      if (provider.exercises.isEmpty) {
        debugPrint('DEBUG: Exercises empty, calling loadExercises()');
        provider.loadExercises();
      } else {
        debugPrint('DEBUG: Exercises already loaded: ${provider.exercises.length} exercises');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.program.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.program.description != null && widget.program.description!.isNotEmpty)
              Text(
                widget.program.description!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );
          }

          final program = provider.activeProgram;
          if (program == null) {
            return const Center(
              child: Text(
                'Program not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final templates = program.templates;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workout Templates',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.orangeAccent),
                      onPressed: () => _showCreateTemplateDialog(context, provider),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Empty state or templates list
                if (templates.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No workout templates yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create your first workout day to get started',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                            ),
                            onPressed: () => _showCreateTemplateDialog(context, provider),
                            icon: const Icon(Icons.add, color: Colors.black),
                            label: const Text(
                              'Create Template',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return _buildTemplateCard(context, template);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build a single template card
  Widget _buildTemplateCard(BuildContext context, WorkoutTemplate template) {
    return Card(
      color: const Color(0xFF2C2C2C),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          template.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${template.exercises.length} exercises',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => _startWorkout(context, template.id),
              child: const Text(
                'Start',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              color: const Color(0xFF2C2C2C),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditTemplateDialog(context, template);
                } else if (value == 'delete') {
                  _showDeleteTemplateConfirmationDialog(context, template);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                      SizedBox(width: 12),
                      Text('Edit', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, color: Colors.white70),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Exercises',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.orangeAccent),
                      onPressed: () => _showAddExerciseDialog(context, template),
                      iconSize: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (template.exercises.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No exercises added yet',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: template.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = template.exercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}.',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.exercise?.name ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${exercise.targetSets} sets × ${exercise.targetReps ?? '?'} reps',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 20),
                              onPressed: () => _showRemoveExerciseConfirmation(
                                context,
                                template,
                                exercise,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show dialog to create a new template
  void _showCreateTemplateDialog(BuildContext context, WorkoutProvider provider) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Create New Workout Day',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Workout day name',
                hintStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Notes (optional)',
                hintStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final template = await provider.createTemplate(
                  name: nameController.text,
                  notes: notesController.text,
                );
                if (mounted) {
                  nav.pop();
                  if (template != null) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Workout day created successfully')),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: ${provider.error}')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// Show dialog to edit a template
  void _showEditTemplateDialog(BuildContext context, WorkoutTemplate template) {
    final nameController = TextEditingController(text: template.name);
    final notesController = TextEditingController(text: template.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Edit Workout Day',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Workout day name',
                hintStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Notes (optional)',
                hintStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final prov = context.read<WorkoutProvider>();
              try {
                await WorkoutService.updateTemplate(
                  templateId: template.id,
                  name: nameController.text,
                  notes: notesController.text,
                  dayOrder: template.dayOrder,
                );
                if (mounted) {
                  await prov.loadTemplatesForActiveProgram();
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Workout day updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation for template
  void _showDeleteTemplateConfirmationDialog(
    BuildContext context,
    WorkoutTemplate template,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Delete Workout Day?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final prov = context.read<WorkoutProvider>();
              try {
                await WorkoutService.deleteTemplate(templateId: template.id);
                if (mounted) {
                  nav.pop();
                  await prov.loadTemplatesForActiveProgram();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Workout day deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Show dialog to add an exercise to a template
  void _showAddExerciseDialog(BuildContext context, WorkoutTemplate template) {
    debugPrint('DEBUG: _showAddExerciseDialog called');
    final provider = context.read<WorkoutProvider>();
    debugPrint('DEBUG: Current exercises in provider: ${provider.exercises.length}');
    debugPrint('DEBUG: Provider isLoading: ${provider.isLoading}');
    showDialog(
      context: context,
      builder: (context) {
        debugPrint('DEBUG: Dialog builder called');
        return Consumer<WorkoutProvider>(
          builder: (context, providerInDialog, _) {
            debugPrint('DEBUG: Consumer builder called, exercises: ${providerInDialog.exercises.length}');
            return _AddExerciseDialog(
              template: template,
              provider: providerInDialog,
            );
          },
        );
      },
    );
  }

  /// Show confirmation to remove exercise from template
  void _showRemoveExerciseConfirmation(
    BuildContext context,
    WorkoutTemplate template,
    TemplateExercise exercise,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Remove Exercise?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${exercise.exercise?.name ?? 'Unknown'}" from this workout?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final prov = context.read<WorkoutProvider>();
              try {
                await WorkoutService.removeExerciseFromTemplate(
                  templateId: template.id,
                  templateExerciseId: exercise.id,
                );
                if (mounted) {
                  nav.pop();
                  await prov.loadTemplatesForActiveProgram();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Exercise removed successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Start a workout session
  void _startWorkout(BuildContext context, int templateId) async {
    final provider = context.read<WorkoutProvider>();
    final session = await provider.startWorkout(templateId);

    if (session != null && mounted) {
      // Navigate to workout screen (will implement this next)
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Workout started! Session ID: ${session.id}'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }
}

/// Separate StatefulWidget for exercise selection dialog
class _AddExerciseDialog extends StatefulWidget {
  final WorkoutTemplate template;
  final WorkoutProvider provider;

  const _AddExerciseDialog({
    required this.template,
    required this.provider,
  });

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  late int? selectedExerciseId;
  late String sortBy;
  late String? filterDifficulty;
  late String? filterMuscle;
  late String searchQuery;
  late bool showSortOptions;
  late bool showFilterOptions;

  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedExerciseId = null;
    sortBy = 'name';
    filterDifficulty = null;
    filterMuscle = null;
    searchQuery = '';
    showSortOptions = false;
    showFilterOptions = false;
  }

  @override
  void dispose() {
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// Get sorted and filtered exercises
  List<Exercise> getSortedExercises(List<Exercise> exercises) {
    var filtered = exercises.where((ex) {
      // Check if all search terms are present in the exercise name
      final matchesSearch = searchQuery.isEmpty || 
          searchQuery.toLowerCase().split(' ').every((term) =>
              term.isEmpty || ex.name.toLowerCase().contains(term));
      final matchesDifficulty = filterDifficulty == null || ex.difficultyLevel == filterDifficulty;
      final matchesMuscle = filterMuscle == null ||
          (ex.primaryMuscles?.contains(filterMuscle) ?? false);

      return matchesSearch && matchesDifficulty && matchesMuscle;
    }).toList();

    filtered.sort((a, b) {
      if (sortBy == 'difficulty') {
        return (a.difficultyLevel ?? '').compareTo(b.difficultyLevel ?? '');
      } else if (sortBy == 'primaryMuscle') {
        final aMuscle =
            a.primaryMuscles?.isNotEmpty ?? false ? a.primaryMuscles!.first : '';
        final bMuscle =
            b.primaryMuscles?.isNotEmpty ?? false ? b.primaryMuscles!.first : '';
        return aMuscle.compareTo(bMuscle);
      }
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    
    debugPrint('DEBUG: _AddExerciseDialog build() called');
    debugPrint('DEBUG: Provider exercises: ${provider.exercises.length}');
    debugPrint('DEBUG: Provider isLoading: ${provider.isLoading}');
    
    // If exercises are still loading, show a loading indicator
    if (provider.exercises.isEmpty && provider.isLoading) {
      debugPrint('DEBUG: Showing loading indicator');
      return AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Add Exercise',
          style: TextStyle(color: Colors.white),
        ),
        content: const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: Colors.orangeAccent),
          ),
        ),
      );
    }

    debugPrint('DEBUG: Getting sorted exercises...');
    final sortedExercises = getSortedExercises(provider.exercises);
    debugPrint('DEBUG: Sorted exercises: ${sortedExercises.length}');

    final muscles = <String>{'None'};
    final difficulties = <String>{'None'};

    for (var ex in provider.exercises) {
      if (ex.difficultyLevel != null) difficulties.add(ex.difficultyLevel!);
      if (ex.primaryMuscles != null) {
        muscles.addAll(ex.primaryMuscles!);
      }
    }

    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: const Text(
        'Add Exercise',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search exercises',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Sort and Filter buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showSortOptions = !showSortOptions;
                          showFilterOptions = false;
                        });
                      },
                      icon: const Icon(Icons.sort),
                      label: const Text('Sort By'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showSortOptions ? Colors.orangeAccent : const Color(0xFF3A3A3A),
                        foregroundColor: showSortOptions ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showFilterOptions = !showFilterOptions;
                          showSortOptions = false;
                        });
                      },
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showFilterOptions ? Colors.orangeAccent : const Color(0xFF3A3A3A),
                        foregroundColor: showFilterOptions ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (showSortOptions) ...[
                const SizedBox(height: 12),
                // Sort options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Name'),
                        selected: sortBy == 'name',
                        onSelected: (_) {
                          setState(() {
                            sortBy = 'name';
                          });
                        },
                        backgroundColor: const Color(0xFF3A3A3A),
                        selectedColor: Colors.orangeAccent,
                        labelStyle: TextStyle(
                          color: sortBy == 'name' ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Difficulty'),
                        selected: sortBy == 'difficulty',
                        onSelected: (_) {
                          setState(() {
                            sortBy = 'difficulty';
                          });
                        },
                        backgroundColor: const Color(0xFF3A3A3A),
                        selectedColor: Colors.orangeAccent,
                        labelStyle: TextStyle(
                          color: sortBy == 'difficulty' ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Muscle'),
                        selected: sortBy == 'primaryMuscle',
                        onSelected: (_) {
                          setState(() {
                            sortBy = 'primaryMuscle';
                          });
                        },
                        backgroundColor: const Color(0xFF3A3A3A),
                        selectedColor: Colors.orangeAccent,
                        labelStyle: TextStyle(
                          color: sortBy == 'primaryMuscle'
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (showFilterOptions) ...[
                const SizedBox(height: 12),
                // Filter dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Difficulty',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Any',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        initialValue: filterDifficulty,
                        items: difficulties.map((d) {
                          return DropdownMenuItem<String?>(
                            value: d == 'None' ? null : d,
                            child: Text(d == 'None' ? 'Any' : d),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            filterDifficulty = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Muscle',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Any',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        initialValue: filterMuscle,
                        items: muscles.toList().map((m) {
                          return DropdownMenuItem<String?>(
                            value: m == 'None' ? null : m,
                            child: Text(m == 'None' ? 'Any' : m),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            filterMuscle = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Exercise list
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: sortedExercises.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No exercises found',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: sortedExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = sortedExercises[index];
                          final isSelected = selectedExerciseId == exercise.id;
                          final primaryMuscle =
                              exercise.primaryMuscles?.isNotEmpty ?? false
                                  ? exercise.primaryMuscles!.first
                                  : 'N/A';

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedExerciseId = exercise.id;
                                });
                              },
                              child: Container(
                                color: isSelected
                                    ? Colors.orangeAccent.withValues(alpha: 0.3)
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.orangeAccent
                                                  : Colors.white,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            '$primaryMuscle${exercise.difficultyLevel != null ? ' • ${exercise.difficultyLevel}' : ''}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.orangeAccent,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              // Sets and Reps side by side
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sets',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'e.g., 3',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Reps',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'e.g., 8-12',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Target weight (lbs) - optional',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
          ),
          onPressed: () async {
            if (selectedExerciseId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an exercise')),
              );
              return;
            }

            final nav = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);
            final prov = context.read<WorkoutProvider>();
            try {
              await prov.addExerciseToTemplate(
                templateId: widget.template.id,
                exerciseId: selectedExerciseId!,
                targetSets: int.tryParse(setsController.text) ?? 3,
                targetReps:
                    repsController.text.isEmpty ? null : repsController.text,
                targetWeightLb: double.tryParse(weightController.text),
              );
              if (mounted) {
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Exercise added successfully')),
                );
              }
            } catch (e) {
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: const Text('Add', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
