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
          child: ElevatedButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: isActive ? AppColors.primary : AppColors.lighterPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.lightPrimary, width: 0),
              ),
              padding: EdgeInsets.all(4),
            ),
            child: Image.asset(
              iconPath,
              color: isActive ? Colors.white : AppColors.darkPrimary,
            ),
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.darkPrimary),
        ),
      ],
    );
  }
}
