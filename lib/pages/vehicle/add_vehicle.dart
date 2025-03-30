import 'package:carlogix_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  // Text controllers
  final _vinController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();
  final _weeklyMileageController = TextEditingController(text: '100'); // Default value
  
  bool _isLoading = false;
  bool _isManualEntry = true; // Toggle between manual entry and VIN lookup
  String? _errorMessage;
  int _weeklyMileage = 0;

  @override
  void dispose() {
    _vinController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    _weeklyMileageController.dispose(); // Add this line
    super.dispose();
  }

  Future<void> _addVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Make sure to call save() on the form to trigger onSaved callbacks
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Prepare the mileage value (required by your API)
      final mileage = int.parse(_mileageController.text);
      
      final result = await _apiService.addVehicle(
        vin: _vinController.text,
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        color: _colorController.text,
        startingMileage: mileage,
        totalMileage: mileage,
        weeklyMileage: _weeklyMileage, // Add this parameter
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success'] == true) {
        // Show success and navigate back
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to add vehicle';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }
  
  Future<void> _lookupVinAndAddVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Make sure to call save() on the form to trigger onSaved callbacks
    _formKey.currentState!.save();
    
    if (_vinController.text.isEmpty || 
        _colorController.text.isEmpty || 
        _mileageController.text.isEmpty) {
      setState(() {
        _errorMessage = 'VIN, color, and mileage are required';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _apiService.decodeVinAndAddVehicle(
        vin: _vinController.text,
        color: _colorController.text,
        startingMileage: int.parse(_mileageController.text),
        weeklyMileage: _weeklyMileage, // Add this parameter
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result['success'] == true) {
        // Show success and navigate back
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle details retrieved and added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to retrieve vehicle details';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
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
          'Add Vehicle',
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle button for entry method
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isManualEntry 
                              ? const Color.fromARGB(255, 219, 21, 21)
                              : Colors.grey.shade300,
                          foregroundColor: _isManualEntry ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isManualEntry = true;
                          });
                        },
                        child: const Text('Manual Entry'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isManualEntry 
                              ? const Color.fromARGB(255, 219, 21, 21)
                              : Colors.grey.shade300,
                          foregroundColor: !_isManualEntry ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isManualEntry = false;
                          });
                        },
                        child: const Text('Lookup VIN'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // VIN Input (required for both methods)
                _buildInputField(
                  label: 'Vehicle Identification Number (VIN)',
                  controller: _vinController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter VIN';
                    }
                    if (value.length != 17) {
                      return 'VIN must be 17 characters';
                    }
                    return null;
                  },
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(17),
                  ],
                ),
                
                // Color Input (required for both methods)
                _buildInputField(
                  label: 'Color',
                  controller: _colorController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the color';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                
                // Mileage Input (required for both methods)
                _buildInputField(
                  label: 'Current Mileage',
                  controller: _mileageController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the mileage';
                    }
                    final mileage = int.tryParse(value);
                    if (mileage == null || mileage < 0) {
                      return 'Please enter a valid mileage';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  hintText: 'Enter current odometer reading',
                ),
                
                // Weekly Mileage Input
                TextFormField(
                  controller: _weeklyMileageController,
                  decoration: InputDecoration(
                    labelText: 'Weekly Mileage Estimate',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    suffixText: 'miles/week',
                    prefixIcon: const Icon(Icons.speed),
                    hintText: '100',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your estimated weekly mileage';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (int.tryParse(value)! < 0) {
                      return 'Weekly mileage cannot be negative';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _weeklyMileage = int.parse(value ?? '100');
                  },
                ),
                
                // Fields for manual entry only
                if (_isManualEntry) ...[
                  // Make Input
                  _buildInputField(
                    label: 'Make',
                    controller: _makeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the make';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  // Model Input
                  _buildInputField(
                    label: 'Model',
                    controller: _modelController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the model';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  // Year Input
                  _buildInputField(
                    label: 'Year',
                    controller: _yearController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the year';
                      }
                      final year = int.tryParse(value);
                      if (year == null) {
                        return 'Please enter a valid year';
                      }
                      final currentYear = DateTime.now().year;
                      if (year < 1900 || year > currentYear + 1) {
                        return 'Please enter a year between 1900 and ${currentYear + 1}';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Add Vehicle Button
                _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 219, 21, 21),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 0,
                      ),
                      onPressed: _isManualEntry ? _addVehicle : _lookupVinAndAddVehicle,
                      child: Text(
                        _isManualEntry ? "Add Vehicle" : "Lookup VIN & Add Vehicle",
                        style: GoogleFonts.raleway(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: const Color(0xffF7F7F9),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(14),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// Text formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}