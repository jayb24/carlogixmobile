import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Base URL for your MERN stack API - replace with your actual server URL
  // For local development with an emulator, use 10.0.2.2 instead of localhost
  // For a physical device, use your computer's IP address on the same network
  final String baseUrl = 'http://159.203.135.123:5000/api'; // Replace with your actual IP or domain
  
  // Storage for user data
  final storage = const FlutterSecureStorage();

  // Register new user - initial step (sends verification email)
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      print('Attempting to register with: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        }),
      );

      // Print response for debugging
      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');
      
      // Check if the response body is empty
      if (response.body.isEmpty) {
        print('Registration failed: Empty response from server');
        return false;
      }
      
      try {
        final data = json.decode(response.body);
        
        if (response.statusCode == 200 && data['success'] == true) {
          // Store email and password temporarily to use during verification
          await storage.write(key: 'temp_email', value: email);
          await storage.write(key: 'temp_password', value: password);
          await storage.write(key: 'temp_firstName', value: firstName);
          await storage.write(key: 'temp_lastName', value: lastName);
          
          return true;
        } else {
          print('Registration failed: ${data['error']}');
          return false;
        }
      } catch (jsonError) {
        print('Error parsing JSON response: $jsonError');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // Verify email with code
  Future<bool> verifyEmail({required String code}) async {
    try {
      final email = await storage.read(key: 'temp_email');
      final password = await storage.read(key: 'temp_password');
      final firstName = await storage.read(key: 'temp_firstName');
      final lastName = await storage.read(key: 'temp_lastName');
      
      if (email == null || password == null || firstName == null || lastName == null) {
        throw Exception('Missing registration data');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Clear temporary storage
        await storage.delete(key: 'temp_email');
        await storage.delete(key: 'temp_password');
        await storage.delete(key: 'temp_firstName');
        await storage.delete(key: 'temp_lastName');
        
        return true;
      } else {
        print('Verification failed: ${data['error']}');
        return false;
      }
    } catch (e) {
      print('Error during verification: $e');
      return false;
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Store user data
        await storage.write(key: 'userId', value: data['userId']);
        await storage.write(key: 'firstName', value: data['firstName']);
        await storage.write(key: 'lastName', value: data['lastName']);
        await storage.write(key: 'email', value: email);
        
        return {
          'success': true,
          'userId': data['userId'],
          'firstName': data['firstName'],
          'lastName': data['lastName'],
        };
      } else {
        print('Login failed: ${data['error']}');
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      print('Error during login: $e');
      return {'success': false, 'error': 'Network error'};
    }
  }

  // Logout user
  Future<void> logout() async {
    // Clear all stored user data
    await storage.delete(key: 'userId');
    await storage.delete(key: 'firstName');
    await storage.delete(key: 'lastName');
    await storage.delete(key: 'email');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final userId = await storage.read(key: 'userId');
    return userId != null;
  }

  // Get current user's authentication token (in this case, userId)
  Future<String?> getToken() async {
    return await storage.read(key: 'userId');
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userId = await storage.read(key: 'userId');
      final firstName = await storage.read(key: 'firstName');
      final lastName = await storage.read(key: 'lastName');
      final email = await storage.read(key: 'email');
      
      if (userId == null || firstName == null || lastName == null || email == null) {
        throw Exception('User data not found');
      }
      
      return {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
    } catch (e) {
      print('Error getting user profile: $e');
      return {'error': 'Failed to load user profile'};
    }
  }

  // Add this method to test server connection
  Future<bool> testConnection() async {
    try {
      print('Testing connection to $baseUrl');
      final response = await http.get(Uri.parse(baseUrl));
      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}