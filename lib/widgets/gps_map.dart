import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:the_town_hall/widgets/location_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_notifier.dart';

class GpsMap extends StatefulWidget {
  const GpsMap({super.key});

  @override
  State<GpsMap> createState() => _GpsMapState();
}

class _GpsMapState extends State<GpsMap> {
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
    if (mounted) {
      Provider.of<LocationNotifier>(context, listen: false)
          .updateGpsLocation(_gpsLocation);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationNotifier>(
      builder: (context, locationNotifier, child) {
        return Scaffold(
          body: Stack(
            children: [
              _buildMap(locationNotifier),
              _buildAttribution(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        );
      },
    );
  }

  Widget _buildMap(LocationNotifier locationNotifier) {
    const double initialZoom = 13.0;

    return Selector<LocationNotifier, LatLng?>(
      selector: (context, notifier) => notifier.targetLocation,
      builder: (context, newLocation, child) {
        if (_isMapReady &&
            newLocation != null &&
            newLocation != _lastMovedLocation) {
          _lastMovedLocation = newLocation;
          _mapController.move(newLocation, initialZoom);
        }

        if (newLocation == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FlutterMap(
          mapController: _mapController,
          options: _buildMapOptions(newLocation, initialZoom),
          children: [
            _buildTileLayer(),
            _buildMarkerLayer(newLocation),
          ],
        );
      },
    );
  }

  MapOptions _buildMapOptions(LatLng initialCenter, double initialZoom) {
    return MapOptions(
      initialCenter: initialCenter,
      initialZoom: initialZoom,
      maxZoom: 20,
      minZoom: 2,
      interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
      onMapReady: () => setState(() {
        _isMapReady = true;
      }),
    );
  }

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.theTownHall',
    );
  }

  Widget _buildMarkerLayer(LatLng location) {
    return MarkerLayer(
      markers: [
        Marker(
          point: location,
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
    );
  }

  Widget _buildAttribution() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(
                      Uri.parse('https://www.openstreetmap.org/copyright'),
                    );
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}