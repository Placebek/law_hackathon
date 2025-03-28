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
  Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(49.8130, 73.0965); // Караганда по умолчанию
  bool _isLoading = true;
  bool _showHeatmap = true; // По умолчанию показываем тепловую карту
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
      _getCurrentLocationAndLoadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Разрешение на местоположение отклонено')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocationAndLoadData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);

      if (_showHeatmap) {
        await _loadHeatmap();
      } else {
        await _loadPoliceStations();
      }

      setState(() => _isLoading = false);

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

  Future<void> _loadHeatmap() async {
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
          radius: HeatmapRadius.fromPixels(20),
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
      _markers = {}; // Очищаем маркеры, если показываем тепловую карту
    });
  }

  Future<void> _loadPoliceStations() async {
    // Предполагается, что у вас есть метод getPoliceStations в CrimeService
    final stations = await _crimeService.getPoliceStations(
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
      distance: 10000,
    );

    setState(() {
      _markers = stations
          .map((station) => Marker(
                markerId: MarkerId(station.id.toString()),
                position: LatLng(station.latitude, station.longitude),
                infoWindow: InfoWindow(
                  title: station.name ?? 'Полицейский участок',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
              ))
          .toSet();
      _heatmaps = {}; // Очищаем тепловую карту, если показываем участки
    });
  }

  void _toggleMapMode() async {
    setState(() {
      _isLoading = true;
      _showHeatmap = !_showHeatmap;
    });

    if (_showHeatmap) {
      await _loadHeatmap();
    } else {
      await _loadPoliceStations();
    }

    setState(() => _isLoading = false);
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
            markers: _markers,
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E88E5),
              ),
            ),
          Positioned(
            top: 55,
            right: 8,
            child: FloatingActionButton(
              onPressed: _toggleMapMode,
              backgroundColor: Colors.white,
              mini: true,
              child: Icon(
                _showHeatmap ? Icons.local_police : Icons.color_lens_outlined,
                color: Color(0xFF1E88E5),
              ),
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
