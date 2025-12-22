import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../services/workout_service.dart';
import 'program_detail_screen.dart';

class WorkoutPlans extends StatefulWidget {
  const WorkoutPlans({super.key});

  @override
  State<WorkoutPlans> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlans> {
  @override
  void initState() {
    super.initState();
    // Load programs and exercises when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadPrograms();
      context.read<WorkoutProvider>().loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );
          }

          if (provider.programs.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Programs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProgramsList(context, provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: () => _showCreateProgramDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  /// Build the list of programs
  Widget _buildProgramsList(BuildContext context, WorkoutProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.programs.length,
      itemBuilder: (context, index) {
        final program = provider.programs[index];

        return Card(
          color: const Color(0xFF2C2C2C),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              program.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              program.description ?? 'No description',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: PopupMenuButton<String>(
              color: const Color(0xFF2C2C2C),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditProgramDialog(context, program);
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context, program, provider);
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
              child: const Icon(Icons.more_vert, color: Colors.orangeAccent),
            ),
            onTap: () {
              // Navigate to program detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgramDetailScreen(program: program),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Build empty state when no programs exist
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            color: Colors.white70,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Workout Programs Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first program to get started',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
            onPressed: () => _showCreateProgramDialog(context),
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              'Create Program',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// Show dialog to create a new program
  void _showCreateProgramDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Create New Program',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Program name',
                hintStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description (optional)',
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
            onPressed: () {
              context.read<WorkoutProvider>().createProgram(
                name: nameController.text,
                description: descriptionController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Create', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// Show dialog to edit an existing program
  void _showEditProgramDialog(BuildContext context, Program program) {
    final nameController = TextEditingController(text: program.name);
    final descriptionController = TextEditingController(text: program.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Edit Program',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Program name',
                hintStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description (optional)',
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
                await WorkoutService.updateProgram(
                  programId: program.id,
                  name: nameController.text,
                  description: descriptionController.text,
                );
                if (mounted) {
                  await prov.loadPrograms();
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Program updated successfully')),
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

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog(
    BuildContext context,
    Program program,
    WorkoutProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Delete Program?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${program.name}"? This action cannot be undone.',
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
              try {
                final success = await provider.deleteProgram(program.id);
                if (mounted) {
                  nav.pop();
                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Program deleted successfully')),
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
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
