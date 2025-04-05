import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SymptomButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;

  const SymptomButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onPressed,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              elevation: 2,
              shadowColor: AppColors.darkPrimary.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppColors.lightPrimary,
                  width: 0.5,
                ),
              ),
              padding: EdgeInsets.all(12),
            ),
            child: Image.asset(
              iconPath,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkPrimary,
          ),
        ),
      ],
    );
  }
}
