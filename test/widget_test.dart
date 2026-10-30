import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_6mouth/app.dart';

void main() {
  testWidgets('main screen lets the player configure and start a quiz', (
    tester,
  ) async {
    await tester.pumpWidget(const QuizApp());

    expect(find.text('Questions amount:'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('start-quiz-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('current-question')), findsOneWidget);
    expect(find.byKey(const ValueKey('question-progress')), findsOneWidget);
    expect(find.byKey(const ValueKey('timer-countdown')), findsOneWidget);
    expect(find.text('1/10'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('answer feedback advances progress and final skip opens result', (
    tester,
  ) async {
    await tester.pumpWidget(const QuizApp());

    final countSlider = tester.widget<Slider>(
      find.byKey(const ValueKey('question-count-slider')),
    );
    countSlider.onChanged!(2);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('start-quiz-button')));
    await tester.pumpAndSettle();

    expect(find.text('1/2'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('answer-1')));
    await tester.pump();

    final selectedAnswerButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('answer-1')),
    );
    expect(selectedAnswerButton.onPressed, isNull);
    expect(
      selectedAnswerButton.style?.backgroundColor?.resolve({}),
      const Color(0xFFFF4B50),
    );
    final correctAnswerButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('answer-0')),
    );
    expect(
      correctAnswerButton.style?.backgroundColor?.resolve({}),
      const Color(0xFF42D9A5),
    );

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('2/2'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('skip-question-button')));
    await tester.pumpAndSettle();
    expect(find.text('Result'), findsOneWidget);
  });
}
