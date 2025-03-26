import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../pages/home/home.dart';
import '../pages/login/login.dart';
import '../pages/verification/verification.dart'; // You'll need to create this
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required BuildContext context
  }) async {
    try {
      final success = await _apiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (success) {
        // Show toast message
        Fluttertoast.showToast(
          msg: "Verification email sent. Please check your inbox.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        
        // Navigate to verification page
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => VerificationPage(email: email)
            )
          );
        }
      } else {
        // Registration failed
        Fluttertoast.showToast(
          msg: "Registration failed. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> verifyEmail({
    required String code,
    required BuildContext context
  }) async {
    try {
      final success = await _apiService.verifyEmail(code: code);

      if (success) {
        // Verification successful
        Fluttertoast.showToast(
          msg: "Email verified! You can now log in.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        
        // Navigate to login page
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Login()
            )
          );
        }
      } else {
        // Verification failed
        Fluttertoast.showToast(
          msg: "Invalid verification code. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    try {
      final result = await _apiService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        // Login successful
        Fluttertoast.showToast(
          msg: "Login successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        
        // Check if the context is still valid
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const Home()
            )
          );
        }
      } else {
        // Login failed
        String errorMessage = result['error'] ?? "Invalid email or password.";
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> signout({
    required BuildContext context
  }) async {
    try {
      await _apiService.logout();
      
      // Show toast
      Fluttertoast.showToast(
        msg: "Logged out successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      
      // Check if the context is still valid
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Login()
          )
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred during logout.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}