import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/quiz_cubit.dart';
import '../data/trivia_api.dart';
import '../models/trivia_category.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/quiz_illustration.dart';
import '../widgets/select_field.dart';
import 'history_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _triviaApi = TriviaApi();

  int _questionCount = 10;
  int _selectedTab = 0;
  int _historyRevision = 0;
  String _category = 'All';
  String _difficulty = 'All';
  List<TriviaCategory> _categories = const [];
  bool _isLoadingCategories = true;
  bool _isStartingQuiz = false;
  String? _categoriesError;
  String? _quizError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _triviaApi.close();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });
    try {
      final categories = await _triviaApi.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        if (_category != 'All' &&
            !categories.any((category) => category.name == _category)) {
          _category = 'All';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingCategories = false;
        _categoriesError = error.toString();
      });
    }
  }

  Future<void> _startQuiz() async {
    if (_isStartingQuiz) return;
    setState(() {
      _isStartingQuiz = true;
      _quizError = null;
    });
    QuizCubit? quizCubit;
    try {
      final categoryId = _category == 'All'
          ? null
          : _categories
                .where((category) => category.name == _category)
                .firstOrNull
                ?.id;
      final questions = await _triviaApi.fetchQuestions(
        amount: _questionCount,
        categoryId: categoryId,
        difficulty: _difficulty,
      );
      if (!mounted) return;
      if (questions.isEmpty) {
        throw StateError('The trivia API returned no questions. Try again.');
      }

      final cubit = QuizCubit(
        questions: questions,
        category: _category,
        difficulty: _difficulty,
        historyRepository: context.read(),
      );
      quizCubit = cubit;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              BlocProvider.value(value: cubit, child: const QuizScreen()),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _quizError = error.toString());
    } finally {
      if (quizCubit != null) await quizCubit.close();
      if (mounted) setState(() => _isStartingQuiz = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _selectedTab == 0
                  ? LayoutBuilder(
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
                                Text(
                                  'Quiz',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text(context),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const Center(child: QuizIllustration()),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Text(
                                      'Questions amount:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.mutedText(context),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_questionCount',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.text(context),
                                      ),
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbColor: AppColors.accent(context),
                                    activeTrackColor: AppColors.accent(context),
                                    inactiveTrackColor: AppColors.track(
                                      context,
                                    ),
                                    overlayColor: AppColors.accent(context)
                                        .withValues(alpha: 0.12),
                                  ),
                                  child: Slider(
                                    key: const ValueKey(
                                      'question-count-slider',
                                    ),
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
                                  options: [
                                    'All',
                                    ..._categories.map(
                                      (category) => category.name,
                                    ),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _category = value),
                                ),
                                if (_isLoadingCategories)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: LinearProgressIndicator(
                                      minHeight: 2,
                                    ),
                                  ),
                                if (_categoriesError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Could not load categories: $_categoriesError',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.danger(context),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Retry loading categories',
                                          onPressed: _isLoadingCategories
                                              ? null
                                              : _loadCategories,
                                          icon: const Icon(Icons.refresh),
                                          color: AppColors.actionBlue(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                SelectField(
                                  label: 'Difficulty',
                                  value: _difficulty,
                                  options: const [
                                    'All',
                                    'Easy',
                                    'Medium',
                                    'Hard',
                                  ],
                                  onChanged: (value) =>
                                      setState(() => _difficulty = value),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : _selectedTab == 1
                  ? HistoryScreen(
                      key: ValueKey(_historyRevision),
                      repository: context.read(),
                    )
                  : SettingsScreen(repository: context.read()),
            ),
            if (_selectedTab == 0) ...[
              if (_quizError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
                  child: Text(
                    _quizError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.danger(context),
                      fontSize: 12,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 4),
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: FilledButton(
                    key: const ValueKey('start-quiz-button'),
                    onPressed: _isStartingQuiz ? null : _startQuiz,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.actionBlue(context),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: _isStartingQuiz
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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
            BottomNavigation(
              selectedIndex: _selectedTab,
              onSelected: (index) => setState(() {
                _selectedTab = index;
                if (index == 1 || index == 2) _historyRevision++;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
