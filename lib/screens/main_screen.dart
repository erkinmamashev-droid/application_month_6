import 'package:flutter/material.dart';

import '../data/quiz_questions.dart';
import '../models/quiz_question.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/quiz_illustration.dart';
import '../widgets/select_field.dart';
import 'quiz_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _questionCount = 10;
  String _category = 'All';
  String _difficulty = 'All';

  List<QuizQuestion> get _availableQuestions => quizQuestions.where((question) {
    final matchesCategory =
        _category == 'All' || question.category == _category;
    final matchesDifficulty =
        _difficulty == 'All' || question.difficulty == _difficulty;
    return matchesCategory && matchesDifficulty;
  }).toList();

  Future<void> _startQuiz() async {
    final available = _availableQuestions;
    if (available.isEmpty) return;
    final selectedQuestions = available.take(_questionCount).toList();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            QuizScreen(questions: selectedQuestions, category: _category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quiz',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Center(child: QuizIllustration()),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              const Text(
                                'Questions amount:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_questionCount',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF33234C),
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbColor: AppColors.purple,
                              activeTrackColor: AppColors.purple,
                              inactiveTrackColor: const Color(0xFFE9E7EB),
                              overlayColor: AppColors.purple.withValues(
                                alpha: 0.12,
                              ),
                            ),
                            child: Slider(
                              key: const ValueKey('question-count-slider'),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              value: _questionCount.toDouble(),
                              onChanged: (value) => setState(
                                () => _questionCount = value.round(),
                              ),
                            ),
                          ),
                          SelectField(
                            label: 'Category',
                            value: _category,
                            options: const [
                              'All',
                              'Geography',
                              'Science',
                              'History',
                            ],
                            onChanged: (value) =>
                                setState(() => _category = value),
                          ),
                          const SizedBox(height: 10),
                          SelectField(
                            label: 'Difficulty',
                            value: _difficulty,
                            options: const ['All', 'Easy', 'Medium'],
                            onChanged: (value) =>
                                setState(() => _difficulty = value),
                          ),
                          const SizedBox(height: 34),
                          Center(
                            child: SizedBox(
                              width: 200,
                              height: 48,
                              child: FilledButton(
                                key: const ValueKey('start-quiz-button'),
                                onPressed: _availableQuestions.isEmpty
                                    ? null
                                    : _startQuiz,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: const Text(
                                  'START',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const BottomNavigation(),
          ],
        ),
      ),
    );
  }
}
