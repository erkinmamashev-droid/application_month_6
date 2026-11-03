import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/quiz_result.dart';

abstract interface class QuizHistoryRepository {
  Future<void> save(QuizResult result);

  Future<List<QuizResult>> getAll();

  Future<void> delete(String id);

  Future<void> deleteAll();
}

class HiveQuizHistoryRepository implements QuizHistoryRepository {
  HiveQuizHistoryRepository(this._box);

  static const boxName = 'quiz_history';

  final Box<String> _box;

  static Future<HiveQuizHistoryRepository> open() async {
    final box = await Hive.openBox<String>(boxName);
    return HiveQuizHistoryRepository(box);
  }

  @override
  Future<void> save(QuizResult result) =>
      _box.put(result.id, jsonEncode(result.toJson()));

  @override
  Future<List<QuizResult>> getAll() async {
    final results = _box.values
        .map(
          (encoded) =>
              QuizResult.fromJson(jsonDecode(encoded) as Map<String, dynamic>),
        )
        .toList();
    results.sort(
      (first, second) => second.completedAt.compareTo(first.completedAt),
    );
    return results;
  }

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  Future<void> deleteAll() => _box.clear();
}

class InMemoryQuizHistoryRepository implements QuizHistoryRepository {
  final List<QuizResult> _results = [];

  @override
  Future<void> save(QuizResult result) async {
    _results.removeWhere((existing) => existing.id == result.id);
    _results.add(result);
  }

  @override
  Future<List<QuizResult>> getAll() async => _results.toList()
    ..sort((first, second) => second.completedAt.compareTo(first.completedAt));

  @override
  Future<void> delete(String id) async {
    _results.removeWhere((result) => result.id == id);
  }

  @override
  Future<void> deleteAll() async {
    _results.clear();
  }
}
