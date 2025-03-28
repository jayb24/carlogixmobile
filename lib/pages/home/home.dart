import 'package:carlogix_mobile/pages/profile/profile.dart';
import 'package:carlogix_mobile/pages/vehicle/add_vehicle.dart';  // Add this import
import 'package:carlogix_mobile/pages/vehicle/vehicle_details.dart';
import 'package:carlogix_mobile/services/api_service.dart';
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
  String _lastName = '';
  String _email = '';
  bool _isLoading = true;
  
  // Add these for vehicles
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoadingVehicles = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVehicles();  // Add this line
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
            _lastName = '';
            _email = 'Not logged in';
            _isLoading = false;
          });
        } else {
          setState(() {
            _firstName = userData['firstName'] ?? 'User';
            _lastName = userData['lastName'] ?? '';
            _email = userData['email'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        // No token found, user isn't logged in
        setState(() {
          _firstName = 'Guest';
          _lastName = '';
          _email = 'Not logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _firstName = 'Error';
        _lastName = '';
        _email = 'Could not load user data';
        _isLoading = false;
      });
    }
  }
  
  // Add this method to load vehicles
  Future<void> _loadVehicles() async {
    try {
      setState(() {
        _isLoadingVehicles = true;
      });
      
      final vehicles = await _apiService.getUserVehicles();
      
      setState(() {
        _vehicles = List<Map<String, dynamic>>.from(vehicles);
        _isLoadingVehicles = false;
      });
    } catch (e) {
      print('Error loading vehicles: $e');
      setState(() {
        _vehicles = [];
        _isLoadingVehicles = false;
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
        actions: [
          // Profile avatar button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  _getInitials(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 219, 21, 21),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                  const SizedBox(height: 20),
                  
                  // My Vehicles section header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Vehicles',
                        style: GoogleFonts.raleway(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          )
                        ),
                      ),
                      if (_vehicles.isNotEmpty)
                        TextButton(
                          onPressed: _loadVehicles,
                          child: Text(
                            'Refresh',
                            style: GoogleFonts.raleway(
                              textStyle: const TextStyle(
                                color: Color.fromARGB(255, 219, 21, 21),
                                fontWeight: FontWeight.bold,
                              )
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Vehicle list or loading indicator
                  Expanded(
                    child: _isLoadingVehicles
                      ? const Center(child: CircularProgressIndicator())
                      : _vehicles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No vehicles added yet',
                                  style: GoogleFonts.raleway(
                                    textStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    )
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first vehicle to get started',
                                  style: GoogleFonts.raleway(
                                    textStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    )
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = _vehicles[index];
                              return _buildVehicleCard(vehicle);
                            },
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
                    onPressed: () async {
                      // Navigate to add vehicle page and wait for result
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddVehiclePage()),
                      );
                      
                      // If a vehicle was added, refresh the vehicles list
                      if (result == true) {
                        _loadVehicles();
                      }
                    },
                    child: Text(
                      "Add Vehicle",
                      style: GoogleFonts.raleway(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 16
                        )
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
  
  // Update this method to properly format mileage and fix all deprecated color properties
  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    // Extract vehicle data, handle both string and int types
    final make = vehicle['make'] ?? '';
    final model = vehicle['model'] ?? '';
    final year = vehicle['year'] ?? '';
    final color = vehicle['color'] ?? '';
    
    // Handle mileage which could be string, int, or double
    var totalMileage = vehicle['totalMileage'];
    int formattedMileage;
    
    if (totalMileage is String) {
      // Try to parse string to double first, then round
      formattedMileage = (double.tryParse(totalMileage) ?? 0).round();
    } else if (totalMileage is double) {
      // Round double to nearest integer
      formattedMileage = totalMileage.round();
    } else if (totalMileage is int) {
      // Already an integer
      formattedMileage = totalMileage;
    } else {
      // Default fallback
      formattedMileage = 0;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              Colors.grey.r.toInt(),
              Colors.grey.g.toInt(),
              Colors.grey.b.toInt(),
              0.1  // opacity value
            ),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            // Navigate to vehicle details page
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VehicleDetailsPage(vehicle: vehicle),
              ),
            );
            
            // If a change was made (like deleting the vehicle), refresh the list
            if (result == true) {
              _loadVehicles();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Car icon or image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Color.fromARGB(255, 219, 21, 21),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Car details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$year $make $model',
                        style: GoogleFonts.raleway(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Text(
                        '$color • ${formattedMileage.toString()} miles',
                        style: GoogleFonts.raleway(
                          textStyle: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
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
