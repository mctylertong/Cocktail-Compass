import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/database_service.dart';

class SettingsViewModel extends ChangeNotifier {
  // Preference keys
  static const String _searchRadiusKey = 'search_radius';
  static const String _pageSizeKey = 'page_size';
  static const String _showDistanceInMilesKey = 'show_distance_miles';

  // Default values
  static const int defaultSearchRadius = 5000; // meters
  static const int defaultPageSize = 10;
  static const bool defaultShowDistanceInMiles = true;

  // Available options
  static const List<int> searchRadiusOptions = [1000, 2000, 5000, 10000, 15000, 25000];
  static const List<int> pageSizeOptions = [5, 10, 15, 20, 25, 50];

  // State
  int _searchRadius = defaultSearchRadius;
  int _pageSize = defaultPageSize;
  bool _showDistanceInMiles = defaultShowDistanceInMiles;
  bool _isInitialized = false;

  // Location permission state
  bool _locationServiceEnabled = false;
  LocationPermission _locationPermission = LocationPermission.denied;
  bool _isCheckingPermission = false;

  // Getters
  int get searchRadius => _searchRadius;
  int get pageSize => _pageSize;
  bool get showDistanceInMiles => _showDistanceInMiles;
  bool get isInitialized => _isInitialized;
  bool get locationServiceEnabled => _locationServiceEnabled;
  LocationPermission get locationPermission => _locationPermission;
  bool get isCheckingPermission => _isCheckingPermission;

  bool get hasLocationPermission =>
      _locationPermission == LocationPermission.always ||
      _locationPermission == LocationPermission.whileInUse;

  bool get isLocationPermissionDeniedForever =>
      _locationPermission == LocationPermission.deniedForever;

  /// Get search radius display string
  String get searchRadiusDisplay {
    if (_showDistanceInMiles) {
      final miles = _searchRadius * 0.000621371;
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      if (_searchRadius >= 1000) {
        return '${(_searchRadius / 1000).toStringAsFixed(1)} km';
      }
      return '$_searchRadius m';
    }
  }

  /// Initialize settings from database
  Future<void> initialize() async {
    if (_isInitialized) return;

    final db = DatabaseService.instance;

    // Load search radius
    final radiusStr = await db.getPreference(_searchRadiusKey);
    if (radiusStr != null) {
      _searchRadius = int.tryParse(radiusStr) ?? defaultSearchRadius;
    }

    // Load page size
    final pageSizeStr = await db.getPreference(_pageSizeKey);
    if (pageSizeStr != null) {
      _pageSize = int.tryParse(pageSizeStr) ?? defaultPageSize;
    }

    // Load distance unit preference
    final milesStr = await db.getPreference(_showDistanceInMilesKey);
    if (milesStr != null) {
      _showDistanceInMiles = milesStr == 'true';
    }

    // Check current location permission status
    await checkLocationPermission();

    _isInitialized = true;
    notifyListeners();
  }

  /// Check current location permission status
  Future<void> checkLocationPermission() async {
    _isCheckingPermission = true;
    notifyListeners();

    try {
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      _locationPermission = await Geolocator.checkPermission();
    } catch (e) {
      // Handle any errors silently
    }

    _isCheckingPermission = false;
    notifyListeners();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    _isCheckingPermission = true;
    notifyListeners();

    try {
      // First check if services are enabled
      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationServiceEnabled) {
        _isCheckingPermission = false;
        notifyListeners();
        return false;
      }

      // Request permission
      _locationPermission = await Geolocator.requestPermission();
      _isCheckingPermission = false;
      notifyListeners();
      return hasLocationPermission;
    } catch (e) {
      _isCheckingPermission = false;
      notifyListeners();
      return false;
    }
  }

  /// Open app settings for permission
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Set search radius
  Future<void> setSearchRadius(int radius) async {
    if (_searchRadius == radius) return;
    _searchRadius = radius;
    notifyListeners();
    await DatabaseService.instance.setPreference(_searchRadiusKey, radius.toString());
  }

  /// Set page size
  Future<void> setPageSize(int size) async {
    if (_pageSize == size) return;
    _pageSize = size;
    notifyListeners();
    await DatabaseService.instance.setPreference(_pageSizeKey, size.toString());
  }

  /// Set distance unit preference
  Future<void> setShowDistanceInMiles(bool value) async {
    if (_showDistanceInMiles == value) return;
    _showDistanceInMiles = value;
    notifyListeners();
    await DatabaseService.instance.setPreference(_showDistanceInMilesKey, value.toString());
  }

  /// Get permission status text
  String get locationPermissionStatusText {
    if (!_locationServiceEnabled) {
      return 'Location services disabled';
    }
    switch (_locationPermission) {
      case LocationPermission.always:
        return 'Always allowed';
      case LocationPermission.whileInUse:
        return 'Allowed while using app';
      case LocationPermission.denied:
        return 'Not granted';
      case LocationPermission.deniedForever:
        return 'Permanently denied';
      case LocationPermission.unableToDetermine:
        return 'Unknown';
    }
  }

  /// Get permission status color
  Color get locationPermissionStatusColor {
    if (!_locationServiceEnabled) {
      return Colors.orange;
    }
    switch (_locationPermission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return Colors.green;
      case LocationPermission.denied:
        return Colors.orange;
      case LocationPermission.deniedForever:
        return Colors.red;
      case LocationPermission.unableToDetermine:
        return Colors.grey;
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _searchRadius = defaultSearchRadius;
    _pageSize = defaultPageSize;
    _showDistanceInMiles = defaultShowDistanceInMiles;
    notifyListeners();

    final db = DatabaseService.instance;
    await db.setPreference(_searchRadiusKey, defaultSearchRadius.toString());
    await db.setPreference(_pageSizeKey, defaultPageSize.toString());
    await db.setPreference(_showDistanceInMilesKey, defaultShowDistanceInMiles.toString());
  }
}
