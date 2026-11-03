class QuizResult {
  const QuizResult({
    required this.id,
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.completedAt,
    this.difficulty = 'All',
  });

  final String id;
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime completedAt;
  final String difficulty;

  int get incorrectAnswers => totalQuestions - correctAnswers;

  int get scorePercent =>
      totalQuestions == 0 ? 0 : (correctAnswers * 100 / totalQuestions).round();

  Map<String, Object> toJson() => {
    'id': id,
    'category': category,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'completedAt': completedAt.toIso8601String(),
    'difficulty': difficulty,
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    id: json['id'] as String,
    category: json['category'] as String,
    totalQuestions: json['totalQuestions'] as int,
    correctAnswers: json['correctAnswers'] as int,
    completedAt: DateTime.parse(json['completedAt'] as String),
    difficulty: json['difficulty'] as String? ?? 'All',
  );
}
