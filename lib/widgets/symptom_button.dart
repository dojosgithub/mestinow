import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SymptomButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final double size;

  const SymptomButton({
    super.key,
    required this.size,
    required this.iconPath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    print('symptom button size: $size');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              elevation: 2,
              shadowColor: AppColors.darkPrimary.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size * 0.25),
                side: BorderSide(color: AppColors.lightPrimary, width: 0.5),
              ),
              padding: EdgeInsets.all(size * 0.1),
            ),
            child: Image.asset(iconPath, color: Colors.white),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.darkPrimary,
          ),
        ),
      ],
    );
  }
}
