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
  bool _vehicleWasUpdated = false;
  
  @override
  void initState() {
    super.initState();
    _vehicle = Map<String, dynamic>.from(widget.vehicle);
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

  // Format date for display
  String _formatDate(dynamic date) {
    if (date == null) return 'Not available';
    
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        return 'Not available';
      }
      
      // Format as "Apr 15, 2025"
      final month = _getMonthAbbreviation(dateTime.month);
      return '$month ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return 'Not available';
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  // Handle rate of change which could be string, int, or double
  String _formatRateOfChange(dynamic rateOfChange) {
    if (rateOfChange == null) return '0';
    
    double rate;
    if (rateOfChange is String) {
      rate = double.tryParse(rateOfChange) ?? 0;
    } else if (rateOfChange is double) {
      rate = rateOfChange;
    } else if (rateOfChange is int) {
      rate = rateOfChange.toDouble();
    } else {
      rate = 0;
    }
    
    // Round to nearest whole number for display
    return rate.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    // Extract and format vehicle data
    final make = _vehicle['make'] ?? 'Unknown';
    final model = _vehicle['model'] ?? 'Unknown';
    final yearValue = _vehicle['year'];
    final year = yearValue != null ? yearValue.toString() : 'Unknown';
    final color = _vehicle['color'] ?? 'Unknown';
    final vin = _vehicle['vin'] ?? 'Unknown';
    final totalMileage = _formatMileage(_vehicle['totalMileage']);
    final startingMileage = _formatMileage(_vehicle['startingMileage']);
    final addedAt = _formatDate(_vehicle['addedAt']);
    final updatedAt = _formatDate(_vehicle['updatedAt']);
    final rateOfChange = _formatRateOfChange(_vehicle['rateOfChange']);
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _vehicleWasUpdated);
        return false;
      },
      child: Scaffold(
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
            onPressed: () => Navigator.pop(context, _vehicleWasUpdated),
          ),
          actions: [
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
            : ListView(
                padding: const EdgeInsets.all(20),
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
                  _buildInfoCard('Added On', addedAt),
                  if (_vehicle['updatedAt'] != null && _vehicle['updatedAt'] != _vehicle['addedAt'])
                    _buildInfoCard('Last Updated', updatedAt),
                  _buildInfoCard('Weekly Mileage', '$rateOfChange miles/week'),
                  
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
                      _showUpdateMileageDialog();
                    },
                  ),
                  
                  // Update weekly mileage button
                  _buildActionButton(
                    'Update Weekly Mileage Estimate',
                    Icons.calendar_month,
                    Colors.teal.shade50,
                    Colors.teal.shade800,
                    () {
                      _showUpdateWeeklyMileageDialog();
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
  
  void _showUpdateMileageDialog() {
    // Create the controller inside the method but don't pass it around
    final currentMileage = _formatMileage(_vehicle['totalMileage']);
    
    // Use a temporary variable to store the mileage input
    String mileageInput = currentMileage;
    String? errorMessage;
    
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Update Mileage',
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the current odometer reading.',
                    style: GoogleFonts.raleway(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Use normal TextField instead of TextFormField
                  TextField(
                    controller: null, // No controller needed
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Update the local variable directly
                      mileageInput = value;
                      
                      // Validate inline
                      if (value.isEmpty) {
                        setState(() => errorMessage = 'Please enter the current mileage');
                      } else {
                        final mileage = int.tryParse(value);
                        if (mileage == null) {
                          setState(() => errorMessage = 'Please enter a valid number');
                        } else if (mileage < 0) {
                          setState(() => errorMessage = 'Mileage cannot be negative');
                        } else {
                          // Get current mileage for comparison
                          int currentMileageInt = 0;
                          final totalMileage = _vehicle['totalMileage'];
                          if (totalMileage is String) {
                            currentMileageInt = (double.tryParse(totalMileage) ?? 0).round();
                          } else if (totalMileage is double) {
                            currentMileageInt = totalMileage.round();
                          } else if (totalMileage is int) {
                            currentMileageInt = totalMileage;
                          }
                          
                          if (mileage < currentMileageInt) {
                            setState(() => errorMessage = 'New mileage cannot be less than current mileage');
                          } else {
                            setState(() => errorMessage = null);
                          }
                        }
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Current Mileage',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      suffixText: 'miles',
                      errorText: errorMessage,
                      // Pre-fill with current mileage
                      hintText: currentMileage,
                    ),
                  ),
                ],
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
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Update',
                    style: GoogleFonts.raleway(
                      textStyle: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Validate before submitting
                    final mileage = int.tryParse(mileageInput);
                    if (mileage == null) {
                      setState(() => errorMessage = 'Please enter a valid number');
                      return;
                    }
                    
                    // Get current mileage for comparison
                    int currentMileageInt = 0;
                    final totalMileage = _vehicle['totalMileage'];
                    if (totalMileage is String) {
                      currentMileageInt = (double.tryParse(totalMileage) ?? 0).round();
                    } else if (totalMileage is double) {
                      currentMileageInt = totalMileage.round();
                    } else if (totalMileage is int) {
                      currentMileageInt = totalMileage;
                    }
                    
                    if (mileage < currentMileageInt) {
                      setState(() => errorMessage = 'New mileage cannot be less than current mileage');
                      return;
                    }
                    
                    Navigator.of(dialogContext).pop();
                    
                    // Update mileage with the parsed value
                    _updateMileage(mileage);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _updateMileage(int newMileage) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final carId = _vehicle['_id'];
      if (carId == null) {
        throw Exception('Vehicle ID is missing');
      }
      
      final result = await _apiService.updateMileage(carId, newMileage);
      
      if (result['success'] == true) {
        // Update the local vehicle data
        if (result['data'] != null && result['data']['car'] != null) {
          setState(() {
            _vehicle = result['data']['car'];
            _isLoading = false;
          });
        } else {
          // If the API doesn't return the updated car, just update the mileage
          setState(() {
            _vehicle['totalMileage'] = newMileage;
            _isLoading = false;
          });
        }
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mileage updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Mark that the vehicle was updated
        _vehicleWasUpdated = true;
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to update mileage'),
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

  void _showUpdateWeeklyMileageDialog() {
    // Extract current weekly mileage
    final currentWeeklyMileage = _formatRateOfChange(_vehicle['rateOfChange']);
    
    // Use a temporary variable to store the mileage input
    String weeklyMileageInput = currentWeeklyMileage;
    String? errorMessage;
    
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Update Weekly Mileage',
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How many miles do you drive per week on average?',
                    style: GoogleFonts.raleway(),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: null, // No controller needed
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      // Update the local variable directly
                      weeklyMileageInput = value;
                      
                      // Validate inline
                      if (value.isEmpty) {
                        setState(() => errorMessage = 'Please enter your weekly mileage');
                      } else {
                        final mileage = int.tryParse(value);
                        if (mileage == null) {
                          setState(() => errorMessage = 'Please enter a valid number');
                        } else if (mileage < 0) {
                          setState(() => errorMessage = 'Weekly mileage cannot be negative');
                        } else {
                          setState(() => errorMessage = null);
                        }
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Weekly Mileage',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      suffixText: 'miles/week',
                      errorText: errorMessage,
                      hintText: currentWeeklyMileage,
                    ),
                  ),
                ],
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
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Update',
                    style: GoogleFonts.raleway(
                      textStyle: TextStyle(
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Validate before submitting
                    final weeklyMileage = int.tryParse(weeklyMileageInput);
                    if (weeklyMileage == null) {
                      setState(() => errorMessage = 'Please enter a valid number');
                      return;
                    }
                    
                    if (weeklyMileage < 0) {
                      setState(() => errorMessage = 'Weekly mileage cannot be negative');
                      return;
                    }
                    
                    Navigator.of(dialogContext).pop();
                    
                    // Update weekly mileage
                    _updateWeeklyMileage(weeklyMileage);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateWeeklyMileage(int weeklyMileage) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final carId = _vehicle['_id'];
      if (carId == null) {
        throw Exception('Vehicle ID is missing');
      }
      
      // Update the vehicle locally for now (you can add an API method later)
      setState(() {
        _vehicle['rateOfChange'] = weeklyMileage;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weekly mileage estimate updated'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Mark that the vehicle was updated
      _vehicleWasUpdated = true;
      
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