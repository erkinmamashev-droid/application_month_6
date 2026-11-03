import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/quiz_cubit.dart';
import '../theme/app_colors.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizCubit _cubit;
  bool _hasCubit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCubit) {
      _cubit = context.read<QuizCubit>();
      _hasCubit = true;
    }
  }

  @override
  void dispose() {
    _cubit.pause();
    super.dispose();
  }

  Color _timerColor(int secondsRemaining) {
    if (secondsRemaining <= 5) return AppColors.danger(context);
    if (secondsRemaining <= 10) return AppColors.warning(context);
    return AppColors.success(context);
  }

  Color _answerColor(BuildContext context, QuizState state, int answerIndex) {
    if (!state.isAnswerLocked) return AppColors.actionBlue(context);
    if (answerIndex == state.currentQuestion.correctAnswer) {
      return AppColors.success(context);
    }
    if (answerIndex == state.selectedAnswer || state.secondsRemaining == 0) {
      return AppColors.danger(context);
    }
    return AppColors.fieldSurface(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizCubit, QuizState>(
      listenWhen: (previous, current) =>
          previous.result == null && current.result != null,
      listener: (context, state) {
        final cubit = context.read<QuizCubit>();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) =>
                BlocProvider.value(value: cubit, child: const ResultScreen()),
          ),
        );
      },
      child: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          final timerColor = _timerColor(state.secondsRemaining);
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          key: const ValueKey('quiz-back-button'),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 40,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            state.category == 'All' ? 'Mixed' : state.category,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        key: const ValueKey('question-progress'),
                        value: state.progress,
                        minHeight: 6,
                        backgroundColor: AppColors.track(context),
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.accent(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.questionIndex + 1}/${state.questions.length}',
                      key: const ValueKey('question-count'),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_outlined, size: 15, color: timerColor),
                        const SizedBox(width: 4),
                        Text(
                          '${state.secondsRemaining} s',
                          key: const ValueKey('timer-countdown'),
                          style: TextStyle(
                            fontSize: 12,
                            color: timerColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.currentQuestion.text,
                      key: const ValueKey('current-question'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.2,
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ...List.generate(state.currentQuestion.answers.length, (
                      index,
                    ) {
                      final answerColor = _answerColor(context, state, index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            key: ValueKey('answer-$index'),
                            onPressed: state.isAnswerLocked
                                ? null
                                : () => context.read<QuizCubit>().chooseAnswer(
                                    index,
                                  ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: answerColor,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              side: BorderSide(
                                color: state.isAnswerLocked
                                    ? answerColor
                                    : AppColors.actionBlue(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              state.currentQuestion.answers[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    state.isAnswerLocked &&
                                        index !=
                                            state
                                                .currentQuestion
                                                .correctAnswer &&
                                        index != state.selectedAnswer &&
                                        state.secondsRemaining != 0
                                    ? AppColors.mutedText(context)
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    SizedBox(
                      height: 42,
                      child: FilledButton(
                        key: const ValueKey('skip-question-button'),
                        onPressed: context.read<QuizCubit>().skipQuestion,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.softPink(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
