import 'package:carlogix_mobile/services/api_service.dart';
import 'package:carlogix_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ApiService _apiService = ApiService();
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get user info from your API
      // This will depend on how your MERN API returns user data
      // Example implementation:
      final token = await _apiService.getToken();
      if (token != null) {
        // You would need to implement getUserProfile in your ApiService
         final userData = await _apiService.getUserProfile();
         setState(() {
           _userEmail = userData['email'];
           _isLoading = false;
         });
        
        // For now, just use a placeholder:
        setState(() {
          _userEmail = 'user@example.com'; // Replace with actual API call later
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userEmail = 'Error loading user data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello👋',
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
                ),
              ),
              const SizedBox(height: 10),
              _isLoading 
                ? CircularProgressIndicator() 
                : Text(
                    _userEmail,
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      )
                    ),
                  ),
              const SizedBox(height: 30),
              _logout(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _logout(BuildContext context) {
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
        await AuthService().signout(context: context);
      },
      child: const Text(
        "Sign Out",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 16
        ),
      ),
    );
  }
}
