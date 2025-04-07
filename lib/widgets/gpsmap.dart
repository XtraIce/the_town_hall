import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For LatLng object

class GpsMap extends StatelessWidget {
  const GpsMap({super.key});
}

  @override
  Widget build(BuildContext context) {
    const LatLng sanMiguelCoords = LatLng(35.7416, -120.6907);
    const double initialZoom = 13.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap example'),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: sanMiguelCoords,
          initialZoom: initialZoom, // higher number = more zoom
          // Add other options like interaction gestures here if needed
          // initialRotation: 0.0,
          // interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            // Alt: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png' with subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.the_town_hall',
            // Additional options for tile layer if needed
            // tileProvider: NetworkTileProvider(), // Default
            // maxZoom: 19,
          ),

          MarkerLayer(markers: [
            Marker(
              point: sanMiguelCoords,
              width: 80,
              height: 80,
              child: Tooltip(
                message: 'San Miguel, CA',
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          ]),
          // Add other layers like PolylineLayer, CircleLayer, etc. if needed
        ],
      )
    );
  }
