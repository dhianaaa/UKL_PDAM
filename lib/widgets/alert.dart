import 'package:flutter/material.dart';

class AlertMessage {
  static void show(BuildContext context, String message, bool isSuccess) {
    final Color fillColor =
        isSuccess ? const Color(0xFFD4F5EC) : const Color(0xFFFFE0E0);
    final Color borderColor =
        isSuccess ? const Color(0xFF26C6A6) : const Color(0xFFE53935);
    final Color iconColor =
        isSuccess ? const Color(0xFF26C6A6) : const Color(0xFFE53935);
    final IconData iconData =
        isSuccess ? Icons.check_circle_rounded : Icons.error_rounded;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(iconData, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}