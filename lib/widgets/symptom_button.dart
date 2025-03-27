import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SymptomButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  const SymptomButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: isActive ? AppColors.primary : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              padding: EdgeInsets.all(8),
            ),
            child: Image.asset(
              iconPath,
              color: isActive ? Colors.white : AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.darkPrimary,
          ),
        ),
      ],
    );
  }
} 