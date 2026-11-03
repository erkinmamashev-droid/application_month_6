class TriviaCategory {
  const TriviaCategory({required this.id, required this.name});

  final int id;
  final String name;

  factory TriviaCategory.fromJson(Map<String, dynamic> json) =>
      TriviaCategory(id: json['id'] as int, name: json['name'] as String);
}
