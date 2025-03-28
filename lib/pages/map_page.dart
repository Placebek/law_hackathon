import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:law_code_flutter/api/crime_service.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  bool _locationPermissionGranted = false;
  Set<Heatmap> _heatmaps = {};
  LatLng _currentPosition = LatLng(43.238949, 76.889709); // Алматы по умолчанию
  bool _isLoading = true;
  final CrimeService _crimeService = CrimeService();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _getCurrentLocationAndLoadCrimes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Разрешение на местоположение отклонено')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocationAndLoadCrimes() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);

      final crimes = await _crimeService.getCrimes(
        latitude: _currentPosition.latitude,
        longitude: _currentPosition.longitude,
        distance: 10000,
      );

      setState(() {
        _heatmaps = {
          Heatmap(
            heatmapId: HeatmapId('crime_heatmap'),
            data: crimes
                .map((crime) => WeightedLatLng(
                      LatLng(crime.latitude, crime.longitude),
                    ))
                .toList(),
            radius:
                HeatmapRadius.fromPixels(20), // Исправлено для HeatmapRadius
            gradient: HeatmapGradient(
              [
                HeatmapGradientColor(Colors.yellow, 0.2),
                HeatmapGradientColor(Colors.orange, 0.5),
                HeatmapGradientColor(Colors.red, 0.9),
              ],
            ),
            opacity: 0.7,
          ),
        };
        _isLoading = false;
      });

      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 12),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Карта',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              if (_controller != null) {
                print('Карта успешно инициализирована');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка инициализации карты')),
                );
              }
            },
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: _locationPermissionGranted,
            heatmaps: _heatmaps,
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E88E5),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
