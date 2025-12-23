import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AiStatsScreen extends StatefulWidget {
  const AiStatsScreen({super.key});

  @override
  State<AiStatsScreen> createState() => _AiStatsScreenState();
}

class _AiStatsScreenState extends State<AiStatsScreen> {
  final AiService _aiService = AiService();
  late Future<AiStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _aiService.getAiStats();
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _aiService.getAiStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('AI Statistics', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _refreshStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        color: Colors.amber,
        backgroundColor: const Color(0xFF2A2A2A),
        child: FutureBuilder<AiStats>(
          future: _statsFuture,
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
                      'Error loading statistics',
                      style: TextStyle(color: Colors.grey[300], fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshStats,
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

            final stats = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsGrid(stats),
                  const SizedBox(height: 24),
                  _buildConversationCard(stats),
                  const SizedBox(height: 16),
                  _buildWorkoutPlansCard(stats),
                  const SizedBox(height: 16),
                  _buildFeedbackCard(stats),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AiStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Conversations',
          value: stats.totalConversations.toString(),
          icon: Icons.chat,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Plans Generated',
          value: stats.totalPlansGenerated.toString(),
          icon: Icons.fitness_center,
          color: Colors.amber,
        ),
        _buildStatCard(
          title: 'Plans Completed',
          value: stats.plansCompleted.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Avg Rating',
          value: stats.avgFeedbackRating.toStringAsFixed(1),
          icon: Icons.star,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(AiStats stats) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Conversation Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Total Messages',
              stats.totalConversations.toString(),
            ),
            const SizedBox(height: 12),
            if (stats.lastConversationAt != null)
              _buildInfoRow(
                'Last Conversation',
                _formatLastConversation(stats.lastConversationAt!),
              )
            else
              _buildInfoRow(
                'Last Conversation',
                'Never',
                valueColor: Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPlansCard(AiStats stats) {
    final completionRate = stats.totalPlansGenerated > 0
        ? (stats.plansCompleted / stats.totalPlansGenerated * 100).toStringAsFixed(1)
        : '0';

    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Workout Plans',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Total Generated', stats.totalPlansGenerated.toString()),
            const SizedBox(height: 12),
            _buildInfoRow('Completed', stats.plansCompleted.toString()),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Completion Rate',
              '$completionRate%',
              valueColor: _getCompletionColor(double.parse(completionRate)),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stats.totalPlansGenerated > 0
                  ? stats.plansCompleted / stats.totalPlansGenerated
                  : 0,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(AiStats stats) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  stats.avgFeedbackRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < stats.avgFeedbackRating.toInt()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Average Rating',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stats.plansCompleted > 0
                  ? 'Based on ${stats.plansCompleted} completed plans'
                  : 'No feedback yet',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatLastConversation(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 75) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.amber;
    } else {
      return Colors.orange;
    }
  }
}
