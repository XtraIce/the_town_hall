import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart'; // For use with flutter_map
import 'package:provider/provider.dart';
import 'location_provider.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  LatLng? _searchResultLocation;
  String _errorMessage = '';

  Future<void> _searchLocation(String locationName) async {
    setState(() {
      _searchResultLocation = null;
      _errorMessage = '';
    });

    try {
      List<Location> locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        setState(() {
          _searchResultLocation =
              LatLng(locations.first.latitude, locations.first.longitude);
          print('Location found: ${_searchResultLocation!.latitude}, ${_searchResultLocation!.longitude}');
          final locationNotifier = Provider.of<LocationNotifier>(context, listen: false);
          locationNotifier.updateSearchedLocation(_searchResultLocation);
        });
      } else {
        setState(() {
          _errorMessage = 'No results found for "$locationName".';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching for location: $e';
      });
      log('Error during geocoding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(minWidth: 360, maxWidth: 720),
        child: 
        Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFECE6F0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child:
            TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                maxLength: 50,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                hintText: 'Enter location name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                  _searchLocation(_searchController.text);
                  },
                ),
                ),
                style: TextStyle(overflow: TextOverflow.visible),
                scrollPadding: EdgeInsets.all(8.0),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                autofillHints: const [AutofillHints.addressCity],
                onSubmitted: (text) {
                  _searchLocation(text);
                },
              ),
          ),
        );
  }
}