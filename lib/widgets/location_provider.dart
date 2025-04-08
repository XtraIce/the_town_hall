import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // If you're using flutter_map

class LocationNotifier extends ChangeNotifier {
  LatLng? _searchedLocation;

  LatLng? get searchedLocation => _searchedLocation;

  void updateSearchedLocation(LatLng? newLocation) {
    _searchedLocation = newLocation;
    notifyListeners(); // Notify any widgets listening to this provider
  }
}