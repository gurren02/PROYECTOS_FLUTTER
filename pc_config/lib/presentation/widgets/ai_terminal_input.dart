import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AiTerminalInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final Color? backgroundColor;
  final Color? borderColor;

  const AiTerminalInput({
    Key? key,
    required this.controller,
    required this.onSubmitted,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background,
        border: Border.all(color: borderColor ?? Colors.black38),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            '> ',
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              cursorColor: Colors.white,
              cursorWidth: 8, // Block cursor effect
              cursorRadius: const Radius.circular(0),
              decoration: InputDecoration(
                hintText: 'Ej. "Quiero una PC para jugar a 4K por menos de \$2000"',
                hintStyle: GoogleFonts.jetBrainsMono(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.accent),
            onPressed: onSubmitted,
          ),
        ],
      ),
    );
  }
}
