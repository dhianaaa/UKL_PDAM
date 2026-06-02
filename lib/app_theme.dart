import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2DB89B); 
  static const Color primaryDark = Color(0xFF1A9B80);     
  static const Color primaryLight = Color(0xFFE8F8F5);
  static const Color background = Color(0xFFF0F4F8);
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF1A2332);
  static const Color textGrey = Color(0xFF8A9BB0);
  static const Color statusBelumDibayar = Color(0xFFFF8C69);
  static const Color statusBelumDiverifikasi = Color(0xFFFFB347);
  static const Color statusDibayar = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFE53935);
  static const Color dangerLight = Color(0xFFFFEBEE);       
  static const Color warning = Color(0xFFFF8F00);           
  static const Color warningLight = Color(0xFFFFF3E0);      
  static const Color success = Color(0xFF4CAF50);           
  static const Color successLight = Color(0xFFE8F5E9);      
  static const Color cardBg = Colors.white;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );
  static const TextStyle grey = TextStyle(
    fontSize: 13,
    color: AppColors.textGrey,
  );
}