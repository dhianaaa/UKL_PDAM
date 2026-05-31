import 'package:amerta_pay/app_theme.dart';
import 'package:flutter/material.dart';

// Status Badge Widget
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'belum_dibayar':
        bg = AppColors.statusBelumDibayar.withOpacity(0.15);
        text = AppColors.statusBelumDibayar;
        label = 'Belum Dibayar';
        break;
      case 'belum_diverifikasi':
        bg = AppColors.statusBelumDiverifikasi.withOpacity(0.15);
        text = AppColors.statusBelumDiverifikasi;
        label = 'Belum Diverifikasi';
        break;
      case 'lunas':
        bg = AppColors.statusDibayar.withOpacity(0.15);
        text = AppColors.statusDibayar;
        label = 'Dibayar';
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        text = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// Custom TextField
class PdamTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;

  const PdamTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// Primary Button
class PdamPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PdamPrimaryButton({Key? key, required this.text, this.onPressed, this.isLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

// Outline Button
class PdamOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;

  const PdamOutlineButton({Key? key, required this.text, this.onPressed, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: textColor ?? AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Info Row
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        ],
      ),
    );
  }
}