import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/theme_cubit.dart';
import 'data/quiz_history_repository.dart';
import 'screens/main_screen.dart';
import 'theme/app_colors.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key, this.historyRepository, this.themeCubit});

  final QuizHistoryRepository? historyRepository;
  final ThemeCubit? themeCubit;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<QuizHistoryRepository>(
      create: (_) => historyRepository ?? InMemoryQuizHistoryRepository(),
      child: BlocProvider<ThemeCubit>(
        create: (_) => themeCubit ?? ThemeCubit(),
        child: BlocBuilder<ThemeCubit, bool>(
          builder: (context, isDark) => MaterialApp(
            title: 'Quiz',
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home: const MainScreen(),
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: isDark ? const Color(0xFFC298DF) : AppColors.purple,
          brightness: brightness,
          surface: isDark ? const Color(0xFF20232B) : Colors.white,
        ).copyWith(
          primary: isDark ? const Color(0xFFC298DF) : AppColors.purple,
          secondary: isDark ? const Color(0xFF9BA5FF) : AppColors.blue,
          error: isDark ? const Color(0xFFFF8A91) : AppColors.red,
          onSurface: isDark ? const Color(0xFFE5E3EA) : AppColors.ink,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF17191F) : Colors.white,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      dividerColor: isDark ? const Color(0xFF353841) : const Color(0xFFF0F0F0),
      cardColor: isDark ? const Color(0xFF20232B) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF17191F) : Colors.white,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF30343E)
            : const Color(0xFF33234C),
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }
}
