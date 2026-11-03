import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavigationItem(
            label: 'Quiz',
            icon: Icons.explore_outlined,
            isSelected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          _NavigationItem(
            label: 'History',
            icon: Icons.public,
            isSelected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
          _NavigationItem(
            label: 'Settings',
            icon: Icons.account_circle_outlined,
            isSelected: selectedIndex == 2,
            onTap: () => onSelected(2),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    selected: isSelected,
    child: Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 2),
          child: Icon(
            icon,
            size: 25,
            color: isSelected
                ? AppColors.accent(context)
                : AppColors.mutedNavigation(context),
          ),
        ),
      ),
    ),
  );
}
