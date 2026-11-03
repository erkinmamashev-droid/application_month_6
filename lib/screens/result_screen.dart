import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/quiz_cubit.dart';
import '../models/quiz_result.dart';
import '../theme/app_colors.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final result = state.result;
        if (result == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        key: const ValueKey('result-back-button'),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      Expanded(
                        child: Text(
                          'Result',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const Spacer(),
                  _ScoreSummary(result: result),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _AnswerSummary(
                          label: 'Correct',
                          value: result.correctAnswers,
                          color: AppColors.success(context),
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AnswerSummary(
                          label: 'Incorrect',
                          value: result.incorrectAnswers,
                          color: AppColors.danger(context),
                          icon: Icons.cancel_outlined,
                        ),
                      ),
                    ],
                  ),
                  if (state.isSaving) ...[
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Saving result...'),
                      ],
                    ),
                  ],
                  if (state.saveError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Could not save your result: ${state.saveError}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.danger(context)),
                    ),
                    TextButton(
                      onPressed: state.isSaving
                          ? null
                          : context.read<QuizCubit>().retrySave,
                      child: const Text('Try again'),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      key: const ValueKey('result-home-button'),
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.actionBlue(context),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text(
                        'BACK TO HOME',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  const _ScoreSummary({required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        width: 176,
        height: 176,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: result.scorePercent / 100,
                strokeWidth: 12,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.softSurface(context),
                valueColor: AlwaysStoppedAnimation(AppColors.accent(context)),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${result.scorePercent}%',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
                Text(
                  'YOUR SCORE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.1,
                    color: AppColors.mutedText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Text(
        result.category == 'All'
            ? 'Mixed quiz complete!'
            : '${result.category} complete!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.text(context),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        '${result.correctAnswers} of ${result.totalQuestions} questions answered correctly',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: AppColors.mutedText(context)),
      ),
    ],
  );
}

class _AnswerSummary extends StatelessWidget {
  const _AnswerSummary({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.text(context)),
            ),
          ],
        ),
      ],
    ),
  );
}
