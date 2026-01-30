import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/store.dart';
import '../services/places_api_service.dart';
import '../services/error_service.dart';

enum LocationStatus {
  initial,
  loading,
  loaded,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  error,
}

class StoresViewModel extends ChangeNotifier {
  Position? _currentPosition;
  List<Store> _stores = [];
  bool _isLoadingLocation = false;
  bool _isLoadingStores = false;
  AppException? _error;
  LocationStatus _locationStatus = LocationStatus.initial;
  int _searchRadiusMeters = 5000;

  // Getters
  Position? get currentPosition => _currentPosition;
  List<Store> get stores => _stores;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isLoadingStores => _isLoadingStores;
  bool get isLoading => _isLoadingLocation || _isLoadingStores;
  AppException? get error => _error;
  String? get errorMessage => _error != null ? ErrorService.getUserMessage(_error!) : null;
  AppErrorType? get errorType => _error?.type;
  bool get hasError => _error != null;
  bool get canRetry => _error != null && ErrorService.isRetryable(_error!.type);
  LocationStatus get locationStatus => _locationStatus;
  int get searchRadiusMeters => _searchRadiusMeters;
  bool get hasLocation => _currentPosition != null;
  bool get hasStores => _stores.isNotEmpty;

  Future<void> initializeLocation() async {
    if (_isLoadingLocation) return;

    _isLoadingLocation = true;
    _error = null;
    _locationStatus = LocationStatus.loading;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationStatus = LocationStatus.serviceDisabled;
        _error = AppException(
          'Location services disabled',
          details: 'Please enable location services in your device settings.',
          type: AppErrorType.location,
        );
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationStatus = LocationStatus.permissionDenied;
          _error = LocationPermissionException('Location permissions are denied.');
          _isLoadingLocation = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationStatus = LocationStatus.permissionDeniedForever;
        _error = LocationPermissionException(
          'Location permissions are permanently denied. Please enable them in settings.',
        );
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      _locationStatus = LocationStatus.loaded;
      _isLoadingLocation = false;
      notifyListeners();

      // Auto-search for stores after getting location
      await searchNearbyStores();
    } on AppException catch (e) {
      _locationStatus = LocationStatus.error;
      _error = e;
      _isLoadingLocation = false;
      notifyListeners();
    } catch (e) {
      _locationStatus = LocationStatus.error;
      _error = AppException(
        'Location error',
        details: e.toString(),
        type: AppErrorType.location,
      );
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> searchNearbyStores() async {
    if (_currentPosition == null) return;
    if (_isLoadingStores) return;

    _isLoadingStores = true;
    _error = null;
    notifyListeners();

    try {
      // Check if API key is configured
      if (!PlacesAPIService.isApiKeyConfigured()) {
        _error = ApiKeyException(
          'Google Places API key not configured. Please add your API key in lib/services/places_api_service.dart',
        );
        _stores = [];
        _isLoadingStores = false;
        notifyListeners();
        return;
      }

      // Search for nearby stores
      final stores = await PlacesAPIService.searchNearbyStores(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusMeters: _searchRadiusMeters,
      );

      _stores = stores;
      _isLoadingStores = false;

      if (stores.isEmpty) {
        _error = NotFoundException(
          'No stores found nearby. Try adjusting your location or search radius.',
        );
      }

      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      _isLoadingStores = false;
      notifyListeners();
    } catch (e) {
      _error = ErrorService.handleException(e);
      _isLoadingStores = false;
      notifyListeners();
    }
  }

  /// Retry the last failed operation
  Future<void> retry() async {
    if (_locationStatus != LocationStatus.loaded) {
      await initializeLocation();
    } else {
      await searchNearbyStores();
    }
  }

  void setSearchRadius(int radiusMeters) {
    if (_searchRadiusMeters != radiusMeters) {
      _searchRadiusMeters = radiusMeters;
      notifyListeners();
    }
  }

  Future<void> refreshStores() async {
    _stores = [];
    notifyListeners();
    await searchNearbyStores();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _currentPosition = null;
    _stores = [];
    _isLoadingLocation = false;
    _isLoadingStores = false;
    _error = null;
    _locationStatus = LocationStatus.initial;
    notifyListeners();
  }
}
