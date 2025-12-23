import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AiPlansScreen extends StatefulWidget {
  const AiPlansScreen({super.key});

  @override
  State<AiPlansScreen> createState() => _AiPlansScreenState();
}

class _AiPlansScreenState extends State<AiPlansScreen> {
  final AiService _aiService = AiService();
  late Future<List<WorkoutPlan>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _plansFuture = _aiService.loadWorkoutPlans();
  }

  Future<void> _refreshPlans() async {
    setState(() {
      _plansFuture = _aiService.loadWorkoutPlans();
    });
  }

  Future<void> _deletePlan(int planId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Delete Plan', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this workout plan? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _aiService.deleteWorkoutPlan(planId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan deleted successfully')),
          );
          _refreshPlans();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete plan: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('AI Workout Plans', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _refreshPlans,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPlans,
        color: Colors.amber,
        backgroundColor: const Color(0xFF2A2A2A),
        child: FutureBuilder<List<WorkoutPlan>>(
          future: _plansFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red[400], size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading plans',
                      style: TextStyle(color: Colors.grey[300], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshPlans,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                      child: const Text('Try Again',
                          style: TextStyle(color: Color(0xFF1A1A1A))),
                    ),
                  ],
                ),
              );
            }

            final plans = snapshot.data ?? [];

            if (plans.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, color: Colors.grey[600], size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No workout plans yet',
                      style: TextStyle(color: Colors.grey[300], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate your first AI workout plan to get started',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return _buildPlanCard(plan);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlanCard(WorkoutPlan plan) {
    final isCompleted = plan.wasCompleted ?? false;

    return Card(
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPlanDetails(plan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.goal ?? 'Untitled Plan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(plan.generatedAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (plan.feedbackRating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${plan.feedbackRating}/5',
                      style: TextStyle(color: Colors.grey[300], fontSize: 12),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _showPlanDetails(plan),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.amber,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deletePlan(plan.id),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlanDetails(WorkoutPlan plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  plan.goal ?? 'Untitled Plan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Generated: ${_formatDate(plan.generatedAt)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (plan.feedbackRating != null || plan.feedbackNotes != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Feedback',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (plan.feedbackRating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '${plan.feedbackRating}/5',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      if (plan.feedbackNotes != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            plan.feedbackNotes!,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                const Text(
                  'Workout Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatWorkoutData(plan.workoutData),
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deletePlan(plan.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Plan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _formatWorkoutData(Map<String, dynamic> data) {
    try {
      return data.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
    } catch (e) {
      return 'Unable to display workout details';
    }
  }
}
