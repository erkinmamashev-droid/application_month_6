import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'theme/app_colors.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}
