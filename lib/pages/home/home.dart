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
  String _firstName = '';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get user info from secure storage
      final token = await _apiService.getToken();
      if (token != null) {
        final userData = await _apiService.getUserProfile();
        
        if (userData.containsKey('error')) {
          setState(() {
            _firstName = 'Guest';
            _email = 'Not logged in';
            _isLoading = false;
          });
        } else {
          setState(() {
            _firstName = userData['firstName'] ?? 'User';
            _email = userData['email'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        // No token found, user isn't logged in
        setState(() {
          _firstName = 'Guest';
          _email = 'Not logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _firstName = 'Error';
        _email = 'Could not load user data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'CarLogix',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22
            )
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message with first name
                  Text(
                    'Hello, $_firstName! 👋',
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24
                      )
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email address in smaller text
                  Text(
                    _email,
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 16
                      )
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Add Content Here - Dashboard Cards
                  Expanded(
                    child: Center(
                      child: Text(
                        'No vehicles added yet.',
                        style: GoogleFonts.raleway(
                          textStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16
                          )
                        ),
                      ),
                    ),
                  ),
                  
                  // Add Vehicle Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 219, 21, 21),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Navigate to add vehicle page
                      // You'll implement this later
                    },
                    child: const Text(
                      "Add Vehicle",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 16
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Logout button
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
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 50),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signout(context: context);
      },
      child: const Text(
        "Sign Out",
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 16
        ),
      ),
    );
  }
}
