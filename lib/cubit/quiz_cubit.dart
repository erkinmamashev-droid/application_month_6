import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/quiz_history_repository.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';

class QuizState {
  const QuizState({
    required this.questions,
    required this.category,
    required this.difficulty,
    required this.answers,
    this.questionIndex = 0,
    this.secondsRemaining = QuizCubit.questionDuration,
    this.selectedAnswer,
    this.isAnswerLocked = false,
    this.result,
    this.isSaving = false,
    this.saveError,
  });

  final List<QuizQuestion> questions;
  final String category;
  final String difficulty;
  final List<int?> answers;
  final int questionIndex;
  final int secondsRemaining;
  final int? selectedAnswer;
  final bool isAnswerLocked;
  final QuizResult? result;
  final bool isSaving;
  final String? saveError;

  QuizQuestion get currentQuestion => questions[questionIndex];

  int get correctAnswers => answers.indexed
      .where(
        (entry) =>
            entry.$2 != null && entry.$2 == questions[entry.$1].correctAnswer,
      )
      .length;

  double get progress => (questionIndex + 1) / questions.length;

  QuizState copyWith({
    List<int?>? answers,
    int? questionIndex,
    int? secondsRemaining,
    int? selectedAnswer,
    bool clearSelectedAnswer = false,
    bool? isAnswerLocked,
    QuizResult? result,
    bool? isSaving,
    String? saveError,
    bool clearSaveError = false,
  }) => QuizState(
    questions: questions,
    category: category,
    difficulty: difficulty,
    answers: answers ?? this.answers,
    questionIndex: questionIndex ?? this.questionIndex,
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    selectedAnswer: clearSelectedAnswer
        ? null
        : selectedAnswer ?? this.selectedAnswer,
    isAnswerLocked: isAnswerLocked ?? this.isAnswerLocked,
    result: result ?? this.result,
    isSaving: isSaving ?? this.isSaving,
    saveError: clearSaveError ? null : saveError ?? this.saveError,
  );
}

class QuizCubit extends Cubit<QuizState> {
  QuizCubit({
    required List<QuizQuestion> questions,
    required String category,
    required String difficulty,
    required this._historyRepository,
  }) : super(
         QuizState(
           questions: List.unmodifiable(questions),
           category: category,
           difficulty: difficulty,
           answers: List<int?>.filled(questions.length, null),
         ),
       ) {
    if (questions.isEmpty) {
      throw ArgumentError.value(questions, 'questions', 'Must not be empty.');
    }
    _startTimer();
  }

  static const questionDuration = 15;

  final QuizHistoryRepository _historyRepository;
  Timer? _countdown;
  Timer? _advance;

  void chooseAnswer(int answerIndex) {
    if (state.isAnswerLocked ||
        answerIndex < 0 ||
        answerIndex >= state.currentQuestion.answers.length) {
      return;
    }

    _countdown?.cancel();
    final answers = List<int?>.of(state.answers)
      ..[state.questionIndex] = answerIndex;
    emit(
      state.copyWith(
        answers: answers,
        selectedAnswer: answerIndex,
        isAnswerLocked: true,
      ),
    );
    _advance = Timer(const Duration(milliseconds: 900), _advanceQuestion);
  }

  void skipQuestion() {
    if (state.result != null) return;
    _countdown?.cancel();
    _advance?.cancel();
    _advanceQuestion();
  }

  void tick() {
    if (state.isAnswerLocked || state.result != null) return;
    if (state.secondsRemaining <= 1) {
      _countdown?.cancel();
      emit(
        state.copyWith(
          secondsRemaining: 0,
          isAnswerLocked: true,
          clearSelectedAnswer: true,
        ),
      );
      _advance = Timer(const Duration(milliseconds: 900), _advanceQuestion);
      return;
    }
    emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
  }

  Future<void> retrySave() async {
    final result = state.result;
    if (result == null || state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearSaveError: true));
    try {
      await _historyRepository.save(result);
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, clearSaveError: true));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, saveError: error.toString()));
    }
  }

  void pause() {
    _countdown?.cancel();
    _advance?.cancel();
  }

  void _startTimer() {
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _advanceQuestion() {
    if (isClosed || state.result != null) return;
    _advance?.cancel();
    if (state.questionIndex == state.questions.length - 1) {
      unawaited(_completeQuiz());
      return;
    }
    emit(
      state.copyWith(
        questionIndex: state.questionIndex + 1,
        secondsRemaining: questionDuration,
        clearSelectedAnswer: true,
        isAnswerLocked: false,
      ),
    );
    _startTimer();
  }

  Future<void> _completeQuiz() async {
    if (state.result != null) return;
    _countdown?.cancel();
    final result = QuizResult(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      category: state.category,
      difficulty: state.difficulty,
      totalQuestions: state.questions.length,
      correctAnswers: state.correctAnswers,
      completedAt: DateTime.now(),
    );
    emit(state.copyWith(result: result, isSaving: true));
    try {
      await _historyRepository.save(result);
      if (isClosed) return;
      emit(state.copyWith(isSaving: false));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, saveError: error.toString()));
    }
  }

  @override
  Future<void> close() {
    pause();
    return super.close();
  }
}
