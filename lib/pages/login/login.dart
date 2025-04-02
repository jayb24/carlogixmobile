import 'package:carlogix_mobile/pages/signup/signup.dart';
import 'package:carlogix_mobile/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carlogix_mobile/pages/login/forgot_password.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _signup(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        // Remove the leading back button
        automaticallyImplyLeading: false, // This line removes the automatic back button
      ),
      body: SafeArea(
        child: SingleChildScrollView(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo Image
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120, // Adjust size as needed
                  height: 60, // Adjust size as needed
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Welcome Back',
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 32
                    )
                  ),
                ),
              ),
              const SizedBox(height: 30), // Reduced from 80 to account for logo
               _emailAddress(),
               const SizedBox(height: 20),
               _password(),
               Align(
                 alignment: Alignment.centerRight,
                 child: TextButton(
                   onPressed: () {
                     showDialog(
                       context: context,
                       builder: (BuildContext context) => const ForgotPasswordDialog(),
                     );
                   },
                   child: Text(
                     'Forgot Password?',
                     style: GoogleFonts.raleway(
                       textStyle: TextStyle(
                         color: const Color.fromARGB(255, 219, 21, 21),
                         fontSize: 14,
                       ),
                     ),
                   ),
                 ),
               ),
               const SizedBox(height: 16),
               const SizedBox(height: 50),
               _signin(context),
            ],
          ),
        ),
      ),
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
        const SizedBox(height: 16,),
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
            fillColor: const Color(0xffF7F7F9) ,
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
        const SizedBox(height: 16,),
        TextField(
          obscureText: true,
          controller: _passwordController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF7F7F9) ,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
          ),
        )
      ],
    );
  }

  Widget _signin(BuildContext context) {
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
        await AuthService().signin(
          email: _emailController.text,
          password: _passwordController.text,
          context: context
        );
      },
      child: const Text(
        "Log in",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 16),
        ),
    );
  }

  Widget _signup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
                text: "New User? ",
                style: TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 16
                ),
              ),
              TextSpan(
                text: "Create Account",
                style: const TextStyle(
                    color: Color(0xff1A1D1E),
                    fontWeight: FontWeight.normal,
                    fontSize: 16
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Signup()
                      ),
                    );
                  }
              ),
          ]
        )
      ),
    );
  }
}
