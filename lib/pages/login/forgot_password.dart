// Create a new file: lib/pages/login/forgot_password_dialog.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carlogix_mobile/services/api_service.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _emailSent = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final result = await _apiService.requestPasswordReset(_emailController.text.trim());
      
      if (result['success']) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'] ?? 'Failed to send password reset email';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        _emailSent ? 'Check Your Email' : 'Forgot Password',
        style: GoogleFonts.raleway(
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: _emailSent 
            ? _buildSuccessContent() 
            : _buildRequestForm(),
      ),
      actions: [
        TextButton(
          child: Text(
            _emailSent ? 'Close' : 'Cancel',
            style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        if (!_emailSent)
          TextButton(
            onPressed: _isLoading ? null : _requestPasswordReset,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color.fromARGB(255, 219, 21, 21),
                    ),
                  )
                : Text(
                    'Send Reset Link',
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 219, 21, 21),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
  
  Widget _buildRequestForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: GoogleFonts.raleway(),
          ),
          const SizedBox(height: 16),
          
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _errorMessage,
                style: GoogleFonts.raleway(
                  textStyle: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 50,
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent a password reset link to:',
          style: GoogleFonts.raleway(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Please check your email and follow the instructions to reset your password.',
          style: GoogleFonts.raleway(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}