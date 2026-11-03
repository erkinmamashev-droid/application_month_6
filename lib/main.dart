import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'cubit/theme_cubit.dart';
import 'data/quiz_history_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final historyRepository = await HiveQuizHistoryRepository.open();
  final preferences = await Hive.openBox<bool>('app_preferences');
  final themeCubit = ThemeCubit(
    preferences: preferences,
    initialDark: preferences.get('dark_mode', defaultValue: false)!,
  );
  runApp(QuizApp(historyRepository: historyRepository, themeCubit: themeCubit));
}
