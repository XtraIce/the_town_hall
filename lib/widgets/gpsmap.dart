import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:the_town_hall/widgets/locationservice.dart'; // For LatLng object
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_provider.dart';

class GpsMap extends StatefulWidget {
  const GpsMap({super.key});

  @override
  State<GpsMap> createState() => _GpsMapState();
}

@override
class _GpsMapState extends State<GpsMap> {
  // This widget is the root of your application.
  LatLng? _currentLocation;
  LatLng? _gpsLocation;
  bool _isGps = true;
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
      _gpsLocation = await _locationService.getCurrentLocation();
      setState(() {
        _currentLocation = _gpsLocation;
        _isGps = true;
        print('Gps location: ${_gpsLocation!.latitude}, ${_gpsLocation!.longitude}');
      });

      if(_currentLocation != null) {

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(_currentLocation!, 13.0); // Move the map to the current location
          print('Current location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');
        });
      } else {
        print('Failed to get current location');
      }
  }

  @override
  Widget build(BuildContext context) {
    const double initialZoom = 13.0;

    return Consumer<LocationNotifier>(
      builder: (context, locationNotifier, child) {
      if (!_isGps)
      {
        final searchedLocation = locationNotifier.searchedLocation;
        if (searchedLocation != null) {
        _currentLocation = searchedLocation;
        print("updated current location with searched location: ${searchedLocation.latitude}, ${searchedLocation.longitude}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(searchedLocation, initialZoom);
        });
        }
      }
      else {
        _isGps = false;
      }
      return Scaffold(
        body: Stack(
        children: [
          _currentLocation == null
            ? const Center(child: CircularProgressIndicator())
            : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
              initialCenter: _currentLocation!, // Use the current location if available
              initialZoom: initialZoom, // higher number = more zoom
              maxZoom: 20,
              minZoom: 2,
              interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all),
              ),
              children: [
              TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.theTownHall',
              ),
              MarkerLayer(markers: [
          Marker(
          point: _currentLocation!,
          width: 80,
          height: 80,
          child: Tooltip(
            message: 'Current Location',
            child: const Stack(
            alignment: Alignment.topCenter,
            fit: StackFit.expand,
            children: [
              Icon(Icons.location_pin,
              color: Colors.blue,
              size: 40,
              ),
              Icon(Icons.person,
              color: Colors.white,
              size: 30)
            ]
            )),
          ),
              ]),
              ],
            ),
          Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: RichText(
              text: TextSpan(
              text: '© ',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
              children: [
          TextSpan(
          text: 'OpenStreetMaps',
          style: TextStyle(
            color: Colors.blue[200],
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
            launchUrl(Uri.parse('https://www.openstreetmap.org/copyright'));
            },
          ),
              ],
              ),
            ),
          ),
          ),
        ],
        ),
        floatingActionButton:
        FloatingActionButton(
          onPressed: _getCurrentLocation,
          child: Icon(Icons.my_location)
        ),
      );
      },
    );
  }
}
