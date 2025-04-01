class VehicleIconHelper {
  /// Get the appropriate image asset path for a vehicle based on make and model
  static String getVehicleImagePath({required String make, required String model}) {
    final makeLC = make.toLowerCase();
    final modelLC = model.toLowerCase();
    
    // List of common SUV keywords
    final suvKeywords = [
      'suv', 'crossover', 'cr-v', 'crv', 'rav4', 'equinox', 'explorer', 'highlander',
      'pilot', 'tahoe', 'suburban', 'expedition', 'outback', 'forester', 'pathfinder', 
      'x5', 'q5', 'gx', 'lx', 'rx', 'nx', 'suburban', 'escape', 'edge', 'traverse',
      'sorento', 'sportage', 'tucson', 'santa fe', 'rogue', 'murano', 'cross'
    ];
    
    // List of common truck keywords
    final truckKeywords = [
      'truck', 'pickup', 'f-150', 'f150', 'silverado', 'sierra', 'ram', 'ranger',
      'tundra', 'tacoma', 'frontier', 'colorado', 'canyon', 'ridgeline', 'titan'
    ];
    
    // List of common van/minivan keywords
    final vanKeywords = [
      'van', 'minivan', 'sienna', 'odyssey', 'pacifica', 'carnival', 'sedona', 
      'grand caravan', 'transit', 'express', 'voyager', 'caravan', 'nv200'
    ];
    
    // Check for SUV
    for (final keyword in suvKeywords) {
      if (modelLC.contains(keyword) || makeLC.contains(keyword)) {
        return 'assets/images/cars/suv.png';
      }
    }
    
    // Check for truck
    for (final keyword in truckKeywords) {
      if (modelLC.contains(keyword) || makeLC.contains(keyword)) {
        return 'assets/images/cars/truck.png';
      }
    }
    
    // Check for van
    for (final keyword in vanKeywords) {
      if (modelLC.contains(keyword) || makeLC.contains(keyword)) {
        return 'assets/images/cars/van.png';
      }
    }
    
    // Default to sedan/regular car
    return 'assets/images/cars/sedan.png';
  }
  
  /// Helper method to get image path from a vehicle data map
  static String getVehicleImageFromData(Map<String, dynamic> vehicle) {
    final make = (vehicle['make'] ?? '').toString();
    final model = (vehicle['model'] ?? '').toString();
    return getVehicleImagePath(make: make, model: model);
  }
}