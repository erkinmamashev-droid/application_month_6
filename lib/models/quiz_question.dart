class QuizQuestion {
  const QuizQuestion({
    required this.category,
    required this.difficulty,
    required this.text,
    required this.answers,
    required this.correctAnswer,
  });

  final String category;
  final String difficulty;
  final String text;
  final List<String> answers;
  final int correctAnswer;
}
