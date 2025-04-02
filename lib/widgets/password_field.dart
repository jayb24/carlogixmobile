// Create a new file: lib/widgets/password_field.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool autofocus;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final String? helperText;
  final Widget? prefixIcon;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.focusNode,
    this.helperText,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      style: GoogleFonts.raleway(
        textStyle: const TextStyle(
          fontSize: 16,
        ),
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          tooltip: _obscureText ? 'Show password' : 'Hide password',
        ),
      ),
    );
  }
}