import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
    final String label;
    final String? hint;
    final TextEditingController controller;
    final TextInputType keyboardType;
    final bool obscureText;
    final IconData? prefixIcon;
    final Widget? suffixIcon;
    final String? Function(String?)? validator;
    final int maxLines;

    const CustomTextField({
        Key? key,
        required this.label,
        this.hint,
        required this.controller,
        this.keyboardType = TextInputType.text,
        this.obscureText = false,
        this.prefixIcon,
        this.suffixIcon,
        this.validator,
        this.maxLines = 1,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
            label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
            ),
            ),
            const SizedBox(height: 8),
            TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
                hintText: hint,
                prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
                ),
            ),
            ),
        ],
        );
    }
}