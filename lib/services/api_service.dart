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

  // Add a new vehicle to the user's account
  Future<Map<String, dynamic>> addVehicle({
    required String vin,
    required String make,
    required String model,
    required int year,
    required String color,
    required int startingMileage,
    required int totalMileage,
    required int weeklyMileage,  // New parameter
  }) async {
    try {
      // Get user ID from storage
      final userId = await storage.read(key: 'userId');
      if (userId == null) {
        return {'success': false, 'error': 'User ID not found. Please log in again.'};
      }

      print('Adding vehicle for user: $userId');
      print('VIN: $vin, Make: $make, Model: $model, Year: $year, Color: $color, Mileage: $startingMileage, Weekly: $weeklyMileage');
      
      final response = await http.post(
        Uri.parse('$baseUrl/cars'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'vin': vin,
          'make': make,
          'model': model,
          'year': year.toString(),
          'color': color,
          'startingMileage': startingMileage,
          'totalMileage': totalMileage,
          'rateOfChange': weeklyMileage.toDouble(),  // Convert weekly mileage to rateOfChange
        }),
      );
      
      print('Add vehicle response status: ${response.statusCode}');
      print('Add vehicle response body: ${response.body}');
      
      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server'};
      }
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to add vehicle'};
      }
    } catch (e) {
      print('Error adding vehicle: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update the decodeVinAndAddVehicle method to include weeklyMileage

  Future<Map<String, dynamic>> decodeVinAndAddVehicle({
    required String vin,
    required String color,
    required int startingMileage,
    required int weeklyMileage,  // New parameter
  }) async {
    try {
      // Get user ID from storage
      final userId = await storage.read(key: 'userId');
      if (userId == null) {
        return {'success': false, 'error': 'User ID not found. Please log in again.'};
      }

      print('Decoding VIN and adding vehicle for user: $userId');
      print('VIN: $vin, Color: $color, Mileage: $startingMileage, Weekly: $weeklyMileage');
      
      final response = await http.post(
        Uri.parse('$baseUrl/decode-vin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'vin': vin,
          'color': color,
          'startingMileage': startingMileage,
          'rateOfChange': weeklyMileage.toDouble(),  // Weekly mileage as rate of change
        }),
      );
      
      print('Decode VIN response status: ${response.statusCode}');
      print('Decode VIN response body: ${response.body}');
      
      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server'};
      }
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to decode VIN'};
      }
    } catch (e) {
      print('Error decoding VIN: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get all vehicles for the current user
  Future<List<Map<String, dynamic>>> getUserVehicles() async {
    try {
      // Get user ID from storage
      final userId = await storage.read(key: 'userId');
      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      print('Fetching vehicles for user: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/cars/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Get vehicles response status: ${response.statusCode}');
      print('Get vehicles response body: ${response.body}');
      
      if (response.body.isEmpty) {
        return [];
      }
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data['cars'] is List) {
          return List<Map<String, dynamic>>.from(data['cars']);
        } else if (data['success'] == true && data['cars'] is List) {
          return List<Map<String, dynamic>>.from(data['cars']);
        }
        return [];
      } else {
        print('Error fetching vehicles: ${data['error']}');
        return [];
      }
    } catch (e) {
      print('Error getting vehicles: $e');
      return [];
    }
  }

  // Delete a vehicle
  Future<Map<String, dynamic>> deleteVehicle(String carId) async {
    try {
      print('Deleting vehicle with ID: $carId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/cars/$carId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Delete vehicle response status: ${response.statusCode}');
      print('Delete vehicle response body: ${response.body}');
      
      if (response.body.isEmpty) {
        return {'success': true, 'message': 'Vehicle deleted successfully'};
      }
      
      final data = response.body.isNotEmpty ? json.decode(response.body) : {};
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to delete vehicle'};
      }
    } catch (e) {
      print('Error deleting vehicle: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Add this method to your ApiService class

  // Update vehicle mileage
  Future<Map<String, dynamic>> updateMileage(String carId, int totalMileage) async {
    try {
      print('Updating mileage for vehicle ID: $carId to $totalMileage');
      
      final response = await http.put(
        Uri.parse('$baseUrl/cars/$carId/update-mileage'),  // Remove the duplicate 'api/'
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'totalMileage': totalMileage,
        }),
      );
      
      print('Update mileage response status: ${response.statusCode}');
      print('Update mileage response body: ${response.body}');
      
      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server'};
      }
      
      // Use a try-catch to handle potential JSON parsing errors
      try {
        final data = json.decode(response.body);
        
        if (response.statusCode == 200) {
          return {'success': true, 'data': data};
        } else {
          return {'success': false, 'error': data['error'] ?? 'Failed to update mileage'};
        }
      } catch (e) {
        print('Error parsing JSON response: $e');
        return {
          'success': false, 
          'error': 'Server returned invalid response format. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error updating mileage: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Add this method to your ApiService class

  // Update weekly mileage estimate (rate of change)
  Future<Map<String, dynamic>> updateWeeklyMileage(String carId, int weeklyMileage) async {
    try {
      print('Updating weekly mileage for vehicle ID: $carId to $weeklyMileage');
      
      final response = await http.put(
        Uri.parse('$baseUrl/cars/$carId/update-weekly-mileage'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'rateOfChange': weeklyMileage,
        }),
      );
      
      print('Update weekly mileage response status: ${response.statusCode}');
      print('Update weekly mileage response body: ${response.body}');
      
      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server'};
      }
      
      try {
        final data = json.decode(response.body);
        
        if (response.statusCode == 200) {
          return {'success': true, 'data': data};
        } else {
          return {'success': false, 'error': data['error'] ?? 'Failed to update weekly mileage'};
        }
      } catch (e) {
        print('Error parsing JSON response: $e');
        return {
          'success': false, 
          'error': 'Server returned invalid response format. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error updating weekly mileage: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

// Request a password reset email
Future<Map<String, dynamic>> requestPasswordReset(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'), // Updated path to match your API
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email}),
    );
    
    print('Password reset request status: ${response.statusCode}');
    print('Password reset request body: ${response.body}');
    
    if (response.body.isEmpty) {
      return {'success': false, 'error': 'Empty response from server'};
    }
    
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'Password reset email sent'};
      } else {
        return {
          'success': false, 
          'error': data['error'] ?? 'Failed to send password reset email',
        };
      }
    } catch (e) {
      print('Error parsing JSON response: $e');
      return {
        'success': false, 
        'error': 'Server returned invalid response. Status: ${response.statusCode}'
      };
    }
  } catch (e) {
    print('Error requesting password reset: $e');
    return {'success': false, 'error': 'Network error. Please try again.'};
  }
}

// Add method to reset password with token
Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password/$token'), // Match the API endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'newPassword': newPassword,
      }),
    );
    
    print('Reset password response status: ${response.statusCode}');
    print('Reset password response body: ${response.body}');
    
    if (response.body.isEmpty) {
      return {'success': false, 'error': 'Empty response from server'};
    }
    
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'Password reset successfully'};
      } else {
        return {
          'success': false, 
          'error': data['error'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      print('Error parsing JSON response: $e');
      return {
        'success': false, 
        'error': 'Server returned invalid response. Status: ${response.statusCode}'
      };
    }
  } catch (e) {
    print('Error resetting password: $e');
    return {'success': false, 'error': 'Network error. Please try again.'};
  }
}

}
