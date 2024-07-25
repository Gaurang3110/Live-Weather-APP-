import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  _CitySelectionScreenState createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  final LatLng _initialPosition = LatLng(26.83928000, 80.92313000);
  LatLng _selectedPosition = LatLng(37.7749, -122.4194);
  String _selectedCity = '';

  void _onMapTap(TapPosition tapPosition, LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _selectedPosition = position;
          _selectedCity = placemarks.first.locality ?? '';
        });
      }
    } catch (error) {
      print("Error fetching placemarks: $error");
    }
  }

  void _onCitySelected() {
    // Pass the selected city back to WeatherScreen using Navigator.pop
    Navigator.pop(context, _selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your City'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _onCitySelected,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 8,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: _onMapTap,
            ),
            children: [
              openStreetMapTileLater,
              MarkerLayer(markers: [
                Marker(
                    point: _selectedPosition,
                    width: 60,
                    height: 60,
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.location_pin, size: 60, color: Colors.red))
              ])
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected City:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _selectedCity,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TileLayer get openStreetMapTileLater => TileLayer(
  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
);
