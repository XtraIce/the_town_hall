import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // If you're using flutter_map
import 'package:geocoding/geocoding.dart';
import 'package:the_town_hall/models/representative_card.dart';

class LocationNotifier extends ChangeNotifier {
  LocationUpdate _locationUpdate = LocationUpdate.none;
  LocationUpdate get locationUpdate => _locationUpdate;

  Map<Representative, LatLng> _filteredRepresentativesLocations = {};

  Map<Representative, LatLng> get filteredRepresentativesLocations =>
      _filteredRepresentativesLocations;

  String? _targetCountry;
  String? get targetCountry => _targetCountry;
  String? _targetUSState;
  String? get targetUSState => _targetUSState;
  String? _targetCounty;
  String? get targetCounty => _targetCounty;
  String? _targetCity;
  String? get targetCity => _targetCity;
  String? _targetNeighborhood;
  String? get targetNeighborhood => _targetNeighborhood;
  int? _targetZipCode;
  int? get targetZipCode => _targetZipCode;

  LatLng? _targetLocation;
  LatLng? get targetLocation => _targetLocation;

  // This is the location searched by the user
  // It is updated when the user clicks on the search button
  // and the location is found
  // It is used to show the searched location on the map
  LatLng? _searchedLocation;
  LatLng? get searchedLocation => _searchedLocation;

  Future<void> updateSearchedLocation(LatLng? newLocation) async {
    _searchedLocation = newLocation;
    _locationUpdate = LocationUpdate.searchedLocation;
    _targetLocation = newLocation;
    await _reverseGeocode(newLocation!); // Reverse geocode the new location
    //_printAllLocations();
    notifyListeners(); // Notify any widgets listening to this provider
  }
  //-----------------------------------------------------------------------

  LatLng? _gpsLocation;
  // This is the current location of the user
  // It is updated when the user clicks on the GPS button
  LatLng? get gpsLocation => _gpsLocation;

  Future<void> updateGpsLocation(LatLng? newLocation) async {
    if (_gpsLocation != newLocation) {
      _gpsLocation = newLocation;
      _locationUpdate = LocationUpdate.currentLocation;
      _targetLocation = newLocation;
      await _reverseGeocode(newLocation!); // Reverse geocode the new location
      //_printAllLocations();
      notifyListeners(); // Notify any widgets listening to this provider
    }
  }

  //----------------------------------------------------------------------

  void updateFilteredRepresentativesLocations(
    List<Representative> newLocations,
  ) async {
    for (var representative in newLocations) {
      try {
        List<Location> locations = await locationFromAddress(
          representative.contactInfo.officeAddress,
        );
        if (locations.isNotEmpty) {
          _filteredRepresentativesLocations[representative] = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
        }
      } catch (e) {
        print('Error geocoding address for ${representative.name}: $e');
      }
    }
    notifyListeners(); // Notify any widgets listening to this provider
  }

  void _printAllLocations() {
    print('Target Location: $targetLocation');
    print('Searched Location: $searchedLocation');
    print('GPS Location: $gpsLocation');
    print('Country: $targetCountry');
    print('US State: $targetUSState');
    print('County: $targetCounty');
    print('City: $targetCity');
    print('Neighborhood: $targetNeighborhood');
    print('Zip Code: $targetZipCode');
  }

  Future<void> _reverseGeocode(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _targetCountry = place.country;
        _targetUSState = place.administrativeArea;
        _targetCounty = place.subAdministrativeArea;
        _targetCity = place.locality;
        _targetNeighborhood = place.subLocality;
        _targetZipCode = int.tryParse(place.postalCode ?? '');
      }
    } catch (e) {
      print('Error during reverse geocoding: $e');
    }
  }
}

enum LocationUpdate { currentLocation, searchedLocation, none }
