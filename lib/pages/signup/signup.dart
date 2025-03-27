import 'package:carlogix_mobile/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Change class to StatefulWidget for interactive validation
class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  
  bool _isPasswordValid = false;
  
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }
  
  void _validatePassword() {
    final password = _passwordController.text;
    // Password regex: at least 8 chars, with 1+ uppercase, 1+ lowercase, 1+ number, 1+ special char
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');
    setState(() {
      _isPasswordValid = passwordRegex.hasMatch(password);
    });
  }
  
  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _loginLink(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        // Keep the leading back button for signup page
        iconTheme: const IconThemeData(
          color: Colors.black, // Set the back arrow color
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Create Account',
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 32
                    )
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _nameField(
                label: 'First Name',
                controller: _firstNameController,
                hint: 'Enter your first name'
              ),
              const SizedBox(height: 20),
              _nameField(
                label: 'Last Name',
                controller: _lastNameController,
                hint: 'Enter your last name'
              ),
              const SizedBox(height: 20),
              _emailAddress(),
              const SizedBox(height: 20),
              _password(),
              const SizedBox(height: 30),
              _signup(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words, // Capitalizes first letter
          decoration: InputDecoration(
            filled: true,
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16
            )
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            filled: true,
            hintText: 'your-email@gmail.com',
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14
            ),
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
          ),
        )
      ],
    );
  }

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16
            )
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          controller: _passwordController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF7F7F9),
            hintText: 'Create a strong password',
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            ),
            // Add these lines for password requirements
            helperText: 'Password must have at least 8 characters, including uppercase, lowercase, number, and special character.',
            helperStyle: TextStyle(
              color: _passwordController.text.isEmpty 
                ? Color(0xff6A6A6A) 
                : (_isPasswordValid ? Colors.green : Colors.red),
              fontSize: 12,
            ),
            helperMaxLines: 2,
            suffixIcon: _passwordController.text.isNotEmpty
              ? Icon(
                  _isPasswordValid ? Icons.check_circle : Icons.error,
                  color: _isPasswordValid ? Colors.green : Colors.red,
                )
              : null,
          ),
        )
      ],
    );
  }

  Widget _signup(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 219, 21, 21),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () async {
        // Only allow signup if password is valid
        if (_isPasswordValid) {
          await _register(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please ensure your password meets all requirements.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: const Text(
        "Create Account",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 16
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    await AuthService().signup(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      context: context
    );
  }

  Widget _loginLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: RichText(
        textAlign: TextAlign.center, // Center align the text
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Already have an account? ",
              style: TextStyle(
                color: Color(0xff6A6A6A),
                fontWeight: FontWeight.normal,
                fontSize: 16
              ),
            ),
            TextSpan(
              text: "Log In",
              style: const TextStyle(
                color: Color(0xff1A1D1E),
                fontWeight: FontWeight.normal,
                fontSize: 16
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                Navigator.pop(context); // Just go back to login page
              }
            ),
          ]
        )
      ),
    );
  }
}