import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String                label;
  final String?               hint;
  final IconData?             prefixIcon;
  final bool                  obscureText;
  final Widget?               suffixIcon;
  final TextInputType?        keyboardType;
  final String? Function(String?)? validator;
  final int                   maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscureText,
      keyboardType: keyboardType,
      maxLines:     obscureText ? 1 : maxLines,
      validator:    validator,
      style:        Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText:  label,
        hintText:   hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
