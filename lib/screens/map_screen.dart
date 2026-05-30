import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String cityName;

  const MapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.cityName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa - $cityName'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: point,
          zoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.clima_brasil',
          ),
          MarkerLayer(
            markers: [
              Marker(
              width: 80,
              height: 80,
              point: point,
              child: const Icon(
                Icons.location_pin,
                color: Colors.redAccent,
                size: 36,
              ),
            ),
            ],
          ),
        ],
      ),
    );
  }
}
