import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:the_town_hall/models/representative_card.dart';
import 'package:the_town_hall/widgets/locationservice.dart'; // For LatLng object
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_notifier.dart';

class GpsMap extends StatefulWidget {
  const GpsMap({super.key});

  @override
  State<GpsMap> createState() => _GpsMapState();
}

@override
class _GpsMapState extends State<GpsMap> {
  // This widget is the root of your application.
  // LatLng? _targetLocation;
  LatLng? _gpsLocation;
  LatLng? _lastMovedLocation;
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    _gpsLocation = await _locationService.getCurrentLocation();
    setState(() {
      // _targetLocation = _gpsLocation;
      final locationNotifier = Provider.of<LocationNotifier>(
        context,
        listen: false,
      );
      locationNotifier.updateGpsLocation(_gpsLocation);
      print(
        'Gps location: ${_gpsLocation!.latitude}, ${_gpsLocation!.longitude}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const double initialZoom = 13.0;

    return Consumer<LocationNotifier>(
      builder: (context, locationNotifier, child) {
        return Scaffold(
          body: Stack(
            children: [
              Selector<LocationNotifier, LatLng?>(
                selector: (context, notifier) => notifier.targetLocation,
                builder: (context, newLocation, child) {
                  if (_isMapReady && 
                      newLocation != null &&
                      newLocation != _lastMovedLocation) {
                    _lastMovedLocation = newLocation;
                    _mapController.move(newLocation, initialZoom);
                  }
                  return newLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: newLocation,
                          initialZoom: initialZoom,
                          maxZoom: 20,
                          minZoom: 2,
                          interactionOptions: InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                          onMapReady: () => setState(() {
                            _isMapReady = true;
                          }),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.theTownHall',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: newLocation,
                                width: 80,
                                height: 80,
                                child: Tooltip(
                                  message: 'Current Location',
                                  child: const Stack(
                                    alignment: Alignment.topCenter,
                                    fit: StackFit.expand,
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        color: Colors.blue,
                                        size: 40,
                                      ),
                                      Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),       
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: '© ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: 'OpenStreetMaps',
                          style: TextStyle(
                            color: Colors.blue[200],
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(
                                    Uri.parse(
                                      'https://www.openstreetmap.org/copyright',
                                    ),
                                  );
                                },
                          ),
                       ],
                    ),
                  ),
                ),
              ),
              ],
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: Icon(Icons.my_location))
        );
      }
    );
  }
}

            