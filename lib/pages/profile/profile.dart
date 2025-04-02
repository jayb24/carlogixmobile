import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carlogix_mobile/services/api_service.dart';
import 'package:carlogix_mobile/services/auth_service.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _firstName = '';
  String _lastName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await _apiService.getUserProfile();
      
      if (userData.containsKey('error')) {
        // Error handling
        setState(() {
          _firstName = 'Not available';
          _lastName = 'Not available';
          _email = 'Not available';
          _isLoading = false;
        });
      } else {
        setState(() {
          _firstName = userData['firstName'] ?? 'Not available';
          _lastName = userData['lastName'] ?? 'Not available';
          _email = userData['email'] ?? 'Not available';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _firstName = 'Error';
        _lastName = 'Error';
        _email = 'Error loading profile';
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
          'My Profile',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 219, 21, 21),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Full name
                  Text(
                    '$_firstName $_lastName',
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Email
                  Text(
                    _email,
                    style: GoogleFonts.raleway(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Sign out button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: const Color.fromARGB(255, 219, 21, 21),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: Text(
                      'Sign Out',
                      style: GoogleFonts.raleway(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await AuthService().signout(context: context);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          alignment: Alignment.centerLeft,
        ),
        icon: Icon(icon, color: Colors.black),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }

  String _getInitials() {
    String initials = '';
    if (_firstName.isNotEmpty) {
      initials += _firstName[0];
    }
    if (_lastName.isNotEmpty) {
      initials += _lastName[0];
    }
    return initials.toUpperCase();
  }
}