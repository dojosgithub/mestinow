import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import 'dart:math';

class BrandText extends StatelessWidget {
  final double? fontSize;
  final Color? color;

  const BrandText({super.key, this.fontSize, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'mestiNow',
      style: GoogleFonts.gabarito(
        fontSize:
            fontSize ??
            (24 / min(2.0, MediaQuery.of(context).textScaler.scale(1.0))),
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.darkPrimary,
        letterSpacing: -0.5,
      ),
    );
  }
}
