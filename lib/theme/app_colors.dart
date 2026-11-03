import 'package:flutter/material.dart';

abstract final class AppColors {
  static const purple = Color(0xFFC44CF2);
  static const blue = Color(0xFF6875F5);
  static const green = Color(0xFF42D9A5);
  static const red = Color(0xFFFF4B50);
  static const pink = Color(0xFFFF5F83);
  static const orange = Color(0xFFFFB547);
  static const mutedPurple = Color(0xFFD4CFD9);
  static const ink = Color(0xFF24152B);

  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color accent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFC298DF)
      : purple;

  static Color actionBlue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF8490C8)
      : blue;

  static Color success(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF79C6A4)
      : green;

  static Color danger(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFE58C91)
      : red;

  static Color warning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFD8B174)
      : orange;

  static Color softPink(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFD68DA8)
      : pink;

  static Color mutedNavigation(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF777985)
      : mutedPurple;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFA8AAB7)
      : const Color(0xFF827B87);

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color fieldSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF252831)
      : Colors.white;

  static Color softSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF2A2632)
      : const Color(0xFFF0EAF3);

  static Color divider(BuildContext context) => Theme.of(context).dividerColor;

  static Color track(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF3B3E48)
      : const Color(0xFFE9E7EB);
}
