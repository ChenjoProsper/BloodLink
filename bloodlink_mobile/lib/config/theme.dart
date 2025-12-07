import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class AppTheme {
    static ThemeData get lightTheme {
        return ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            error: AppColors.error,
        ),
        
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            ),
            headlineMedium: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            ),
            bodyLarge: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            ),
            bodyMedium: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        
        cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        );
    }
}