import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? suffixText;
  final String? prefixText;
  final String? helperText;
  final int maxLines;
  final VoidCallback? onChanged;

  const SettingsTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.suffixText,
    this.prefixText,
    this.helperText,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (label.contains("Nama Toko"))
              const Icon(LucideIcons.store, size: 16, color: Colors.grey),
            if (label.contains("Alamat"))
              const Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
            if (label.contains("Telepon"))
              const Icon(LucideIcons.phone, size: 16, color: Colors.grey),
            if (label.contains("Tax"))
              const Icon(LucideIcons.percent, size: 16, color: Colors.grey),
            if (label.contains("Biaya"))
              const Icon(LucideIcons.truck, size: 16, color: Colors.grey),
            if (label.contains("Footer"))
              const Icon(LucideIcons.receiptText, size: 16, color: Colors.grey),
            if (label.contains("Nama") ||
                label.contains("Alamat") ||
                label.contains("Telepon") ||
                label.contains("Tax") ||
                label.contains("Biaya") ||
                label.contains("Footer"))
              const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (val) {
            onChanged?.call();
          },
          decoration: InputDecoration(
            isDense: true,
            hintText: "Masukkan $label",
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.orange.shade600,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixText: suffixText,
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText!,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ]
      ],
    );
  }
}
