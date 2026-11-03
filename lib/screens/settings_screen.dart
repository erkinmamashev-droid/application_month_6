import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../cubit/theme_cubit.dart';
import '../data/quiz_history_repository.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.repository});

  final QuizHistoryRepository repository;

  Future<void> _clearHistory(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All saved quiz results will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
    if (shouldClear != true || !context.mounted) return;

    try {
      await repository.deleteAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('History cleared')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not clear history: $error')),
      );
    }
  }

  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: 'Try Quiz and challenge your knowledge!'),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz invitation copied to clipboard')),
    );
  }

  Future<void> _toggleTheme(BuildContext context) async {
    try {
      await context.read<ThemeCubit>().toggle();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save theme preference: $error')),
      );
    }
  }

  void _showUnavailableMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not configured for this app yet.')),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(22, 10, 22, 20),
        child: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.text(context),
          ),
        ),
      ),
      Divider(height: 1, color: AppColors.divider(context)),
      _ThemeSetting(onChanged: () => _toggleTheme(context)),
      _SettingsRow(title: 'Share this app', onTap: () => _share(context)),
      _SettingsRow(
        title: 'Rate us',
        onTap: () => _showUnavailableMessage(context, 'Store rating'),
      ),
      _SettingsRow(
        title: 'Leave feedback',
        onTap: () => _showUnavailableMessage(context, 'Feedback'),
      ),
      _SettingsRow(
        title: 'Clear history',
        accent: true,
        onTap: () => _clearHistory(context),
      ),
      const Spacer(),
      Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'v 1.0.0',
            style: TextStyle(fontSize: 11, color: AppColors.mutedText(context)),
          ),
        ),
      ),
    ],
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.onTap,
    this.accent = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 23),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: accent
                    ? AppColors.accent(context)
                    : AppColors.text(context),
              ),
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: AppColors.accent(context)),
        ],
      ),
    ),
  );
}

class _ThemeSetting extends StatelessWidget {
  const _ThemeSetting({required this.onChanged});

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 23),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark mode',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDark ? 'Easy on the eyes' : 'Light appearance',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText(context),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            key: const ValueKey('theme-mode-switch'),
            value: isDark,
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}
