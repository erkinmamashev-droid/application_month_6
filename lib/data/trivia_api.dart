import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

import '../models/quiz_question.dart';
import '../models/trivia_category.dart';

class TriviaApi {
  TriviaApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://opentdb.com/',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  void close() => _dio.close();

  Future<List<TriviaCategory>> fetchCategories() async {
    final response = await _get('api_category.php');
    final categories = response['trivia_categories'];
    if (categories is! List) {
      throw const FormatException('The category response is invalid.');
    }

    return categories
        .map(
          (category) => TriviaCategory.fromJson(
            Map<String, dynamic>.from(category as Map),
          ),
        )
        .toList();
  }

  Future<List<QuizQuestion>> fetchQuestions({
    required int amount,
    int? categoryId,
    String difficulty = 'All',
  }) async {
    final query = <String, Object>{
      'amount': amount,
      'type': 'multiple',
      'encode': 'base64',
    };
    if (categoryId != null) query['category'] = categoryId;
    if (difficulty != 'All') query['difficulty'] = difficulty.toLowerCase();

    final response = await _get('api.php', queryParameters: query);
    final responseCode = response['response_code'];
    if (responseCode is! int) {
      throw const FormatException('The question response is invalid.');
    }
    if (responseCode != 0) {
      throw StateError(_responseCodeMessage(responseCode));
    }

    final results = response['results'];
    if (results is! List) {
      throw const FormatException('The question list is invalid.');
    }

    return results.map((item) {
      final question = Map<String, dynamic>.from(item as Map);
      final answers = [
        ...(question['incorrect_answers'] as List)
            .cast<String>()
            .map(_decode)
            .map((answer) => (text: answer, isCorrect: false)),
        (text: _decode(question['correct_answer'] as String), isCorrect: true),
      ]..shuffle(Random());

      return QuizQuestion(
        category: _decode(question['category'] as String),
        difficulty: (question['difficulty'] as String).toLowerCase(),
        text: _decode(question['question'] as String),
        answers: answers.map((answer) => answer.text).toList(),
        correctAnswer: answers.indexWhere((answer) => answer.isCorrect),
      );
    }).toList();
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, Object>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is! Map) {
        throw const FormatException('The trivia API returned invalid data.');
      }
      return Map<String, dynamic>.from(data);
    } on DioException catch (error) {
      throw StateError(_networkErrorMessage(error));
    }
  }

  String _decode(String value) => utf8.decode(base64.decode(value));

  String _responseCodeMessage(int code) => switch (code) {
    1 => 'Not enough questions are available for this selection. Try fewer questions or another category.',
    2 => 'The trivia API rejected the selected options. Please change the quiz settings.',
    3 || 4 =>
      'The trivia API could not provide questions right now. Please try again.',
    5 => 'The trivia API is busy. Wait a few seconds and try again.',
    _ => 'The trivia API returned an unexpected response ($code).',
  };

  String _networkErrorMessage(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      'The trivia API request timed out. Check your connection and try again.',
    DioExceptionType.connectionError =>
      'Could not connect to the trivia API. Check your internet connection.',
    _ => 'Could not load trivia data: ${error.message ?? error.type.name}.',
  };
}
