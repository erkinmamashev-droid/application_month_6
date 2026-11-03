import 'package:flutter/material.dart';

import '../data/quiz_history_repository.dart';
import '../models/quiz_result.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.repository});

  final QuizHistoryRepository repository;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<QuizResult>> _history;

  @override
  void initState() {
    super.initState();
    _history = widget.repository.getAll();
  }

  Future<void> _refresh() async {
    final request = widget.repository.getAll();
    setState(() => _history = request);
    await request;
  }

  Future<void> _delete(String id) async {
    try {
      await widget.repository.delete(id);
      if (mounted) await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete result: $error')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text(
            'History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<QuizResult>>(
            future: _history,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Could not load history: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.danger(context)),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final results = snapshot.data!;
              if (results.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 120),
                      Icon(
                        Icons.history,
                        size: 52,
                        color: AppColors.mutedNavigation(context),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No quiz results yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text(context),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Complete a quiz and your results will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.mutedText(context)),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return _HistoryCard(
                      result: result,
                      formattedDate: _formatDate(result.completedAt),
                      onDelete: () => _delete(result.id),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.result,
    required this.formattedDate,
    required this.onDelete,
  });

  final QuizResult result;
  final String formattedDate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    height: 92,
    padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
    decoration: BoxDecoration(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 18,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Category: ${result.category == 'All' ? 'Mixed' : result.category}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text(context),
                ),
              ),
            ),
            SizedBox(
              height: 24,
              width: 30,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                tooltip: 'History item options',
                icon: Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: AppColors.mutedText(context),
                ),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete result')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          'Correct answers: ${result.correctAnswers}/${result.totalQuestions}',
          style: TextStyle(fontSize: 11, color: AppColors.mutedText(context)),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Difficulty: ${result.difficulty}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText(context),
                  ),
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
