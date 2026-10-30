import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class QuizIllustration extends StatelessWidget {
  const QuizIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 9,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(0.7)..rotateZ(0.78),
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.purple.withValues(alpha: 0.55),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            child: Icon(
              Icons.hourglass_empty_rounded,
              size: 59,
              color: AppColors.blue.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            bottom: 20,
            child: Icon(
              Icons.hourglass_bottom_rounded,
              size: 43,
              color: AppColors.purple.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }
}
