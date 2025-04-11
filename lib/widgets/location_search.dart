import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart'; // For use with flutter_map
import 'package:provider/provider.dart';
import 'location_notifier.dart';

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
      final locationNotifier = Provider.of<LocationNotifier>(context, listen: false);
      List<Location> locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        final newLocation = LatLng(locations.first.latitude, locations.first.longitude);
        await locationNotifier.updateSearchedLocation(newLocation);
        if (mounted) {
          setState(() {
            _searchResultLocation = newLocation;
            print('Location found: ${_searchResultLocation!.latitude}, ${_searchResultLocation!.longitude}');
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No results found for "$locationName".';
        });
      }
    } catch (e) {
      log('Error during geocoding: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 360, maxWidth: 720),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            width: double.infinity,
            height: 70,
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 8),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFECE6F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              maxLines: 1,
              maxLength: 50,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: 'Enter location name',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                suffixIcon: IconButton(
                  alignment: Alignment.topCenter,
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchLocation(_searchController.text);
                  },
                ),
              ),
              style: const TextStyle(overflow: TextOverflow.visible),
              scrollPadding: const EdgeInsets.all(8.0),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              autofillHints: const [AutofillHints.addressCity],
              onSubmitted: (text) {
                _searchLocation(text);
              },
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            ),
          ),
          const SizedBox(height: 8),
          // Display the error message if it exists
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}