import 'package:carlogix_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleDetailsPage extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  
  const VehicleDetailsPage({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late Map<String, dynamic> _vehicle;
  
  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }
  
  // Format mileage to remove decimal places
  String _formatMileage(dynamic mileage) {
    if (mileage is String) {
      return (double.tryParse(mileage) ?? 0).round().toString();
    } else if (mileage is double) {
      return mileage.round().toString();
    } else if (mileage is int) {
      return mileage.toString();
    }
    return '0';
  }

  @override
  Widget build(BuildContext context) {
    final make = _vehicle['make'] ?? 'Unknown';
    final model = _vehicle['model'] ?? 'Unknown';
    
    // Handle year which could be int or string
    final yearValue = _vehicle['year'];
    final year = yearValue != null ? yearValue.toString() : 'Unknown';
    
    final color = _vehicle['color'] ?? 'Unknown';
    final vin = _vehicle['vin'] ?? 'Unknown';
    final totalMileage = _formatMileage(_vehicle['totalMileage']);
    final startingMileage = _formatMileage(_vehicle['startingMileage']);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$year $make $model',
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
        actions: [
          // Add menu for future options like edit, delete
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit vehicle coming soon!'))
                  );
                case 'delete':
                  _showDeleteConfirmation();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Edit Vehicle')
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Delete Vehicle', style: TextStyle(color: Colors.red))
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle image/icon card
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.directions_car,
                        color: Color.fromARGB(255, 219, 21, 21),
                        size: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Vehicle stats section
                  Text(
                    'Vehicle Information',
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Vehicle information cards
                  _buildInfoCard('Make', make),
                  _buildInfoCard('Model', model),
                  _buildInfoCard('Year', year),
                  _buildInfoCard('Color', color),
                  _buildInfoCard('VIN', vin),
                  _buildInfoCard('Current Mileage', '$totalMileage miles'),
                  _buildInfoCard('Starting Mileage', '$startingMileage miles'),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons section
                  Text(
                    'Actions',
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Update mileage button
                  _buildActionButton(
                    'Update Mileage',
                    Icons.edit_road,
                    Colors.blue.shade50,
                    Colors.blue.shade800,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Update mileage coming soon!'))
                      );
                    },
                  ),
                  
                  // Add maintenance button
                  _buildActionButton(
                    'Add Maintenance Record',
                    Icons.build_circle,
                    Colors.amber.shade50,
                    Colors.amber.shade800,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add maintenance coming soon!'))
                      );
                    },
                  ),
                  
                  // View service history button
                  _buildActionButton(
                    'View Service History',
                    Icons.history,
                    Colors.green.shade50,
                    Colors.green.shade800,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Service history coming soon!'))
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.raleway(
              textStyle: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Vehicle',
            style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this vehicle? This action cannot be undone.',
            style: GoogleFonts.raleway(),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteVehicle();
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _deleteVehicle() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final carId = _vehicle['_id'];
      if (carId == null) {
        throw Exception('Vehicle ID is missing');
      }
      
      final result = await _apiService.deleteVehicle(carId);
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success'] == true) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Return true to trigger refresh
      } else {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to delete vehicle'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}