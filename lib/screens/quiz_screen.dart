import 'dart:async';

import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../theme/app_colors.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.questions,
    required this.category,
  });

  final List<QuizQuestion> questions;
  final String category;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _questionDuration = 15;
  Timer? _timer;
  Timer? _feedbackTimer;
  int _questionIndex = 0;
  int _secondsRemaining = _questionDuration;
  int? _selectedAnswer;
  bool _isAnswerLocked = false;

  QuizQuestion get _question => widget.questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = _questionDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isAnswerLocked) return;
      if (_secondsRemaining <= 1) {
        setState(() {
          _secondsRemaining = 0;
          _selectedAnswer = null;
          _isAnswerLocked = true;
        });
        timer.cancel();
        _advanceAfterDelay();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _chooseAnswer(int answerIndex) {
    if (_isAnswerLocked) return;
    _timer?.cancel();
    setState(() {
      _selectedAnswer = answerIndex;
      _isAnswerLocked = true;
    });
    _advanceAfterDelay();
  }

  void _advanceAfterDelay() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_questionIndex == widget.questions.length - 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const ResultScreen()),
        );
        return;
      }
      setState(() {
        _questionIndex++;
        _selectedAnswer = null;
        _isAnswerLocked = false;
        _startTimer();
      });
    });
  }

  void _skipQuestion() {
    _timer?.cancel();
    _feedbackTimer?.cancel();
    if (_questionIndex == widget.questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ResultScreen()),
      );
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedAnswer = null;
      _isAnswerLocked = false;
      _startTimer();
    });
  }

  Color get _timerColor {
    if (_secondsRemaining <= 5) return AppColors.red;
    if (_secondsRemaining <= 10) return AppColors.orange;
    return AppColors.green;
  }

  Color _answerColor(int answerIndex) {
    if (!_isAnswerLocked) return AppColors.blue;
    if (answerIndex == _question.correctAnswer) return AppColors.green;
    if (answerIndex == _selectedAnswer || _secondsRemaining == 0) {
      return AppColors.red;
    }
    return const Color(0xFFE8E8EF);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_questionIndex + 1) / widget.questions.length;
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
                      widget.category == 'All' ? 'Mixed' : widget.category,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        key: const ValueKey('question-progress'),
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE3E3E3),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.purple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_questionIndex + 1}/${widget.questions.length}',
                key: const ValueKey('question-count'),
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, size: 15, color: _timerColor),
                  const SizedBox(width: 4),
                  Text(
                    '$_secondsRemaining s',
                    key: const ValueKey('timer-countdown'),
                    style: TextStyle(
                      fontSize: 12,
                      color: _timerColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _question.text,
                key: const ValueKey('current-question'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.2,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              ...List.generate(
                _question.answers.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      key: ValueKey('answer-$index'),
                      onPressed: _isAnswerLocked
                          ? null
                          : () => _chooseAnswer(index),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _answerColor(index),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        side: BorderSide(
                          color: _isAnswerLocked
                              ? _answerColor(index)
                              : AppColors.blue,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        _question.answers[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              _isAnswerLocked &&
                                  index != _question.correctAnswer &&
                                  index != _selectedAnswer &&
                                  _secondsRemaining != 0
                              ? const Color(0xFF757575)
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 42,
                child: FilledButton(
                  key: const ValueKey('skip-question-button'),
                  onPressed: _skipQuestion,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
