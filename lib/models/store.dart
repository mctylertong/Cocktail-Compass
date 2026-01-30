import 'package:google_maps_flutter/google_maps_flutter.dart';

class Store {
  final String id;
  final String name;
  final String address;
  final LatLng coordinate;
  final double? distance;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinate,
    this.distance,
  });
}
