import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(28, 12, 28, 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.explore_outlined, size: 25, color: AppColors.purple),
          Icon(Icons.public, size: 25, color: AppColors.mutedPurple),
          Icon(
            Icons.account_circle_outlined,
            size: 25,
            color: AppColors.mutedPurple,
          ),
        ],
      ),
    );
  }
}
