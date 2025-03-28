// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:law_code_flutter/api/crime_service.dart';

// class HeatmapPage extends StatefulWidget {
//   @override
//   _HeatmapPageState createState() => _HeatmapPageState();
// }

// class _HeatmapPageState extends State<HeatmapPage> {
//   GoogleMapController? _controller;
//   final CrimeService _crimeService = CrimeService();
//   Set<Heatmap> _heatmaps = {};
//   LatLng _currentPosition = LatLng(43.238949, 76.889709); // Алматы по умолчанию
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocationAndLoadCrimes();
//   }

//   Future<void> _getCurrentLocationAndLoadCrimes() async {
//     try {
//       // Проверка разрешений
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Разрешение на геолокацию отклонено')),
//           );
//           return;
//         }
//       }

//       // Получение текущей позиции
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _currentPosition = LatLng(position.latitude, position.longitude);

//       // Загрузка данных о преступлениях
//       final crimes = await _crimeService.getCrimes(
//         latitude: _currentPosition.latitude,
//         longitude: _currentPosition.longitude,
//         distance: 5000, // 5 км, можно настроить
//       );

//       // Создание тепловой карты с исправленным синтаксисом
//       setState(() {
//         _heatmaps = {
//           Heatmap(
//             heatmapId: HeatmapId('crime_heatmap'),
//             data: crimes
//                 .map((crime) => WeightedLatLng(
//                       LatLng(crime.latitude,
//                           crime.longitude), // Позиционный аргумент
//                       intensity: 1, // Вес точки
//                     ))
//                 .toList(),
//             radius: 20,
//             gradient: HeatmapGradient(
//               [
//                 Colors.yellow,
//                 Colors.orange,
//                 Colors.red
//               ], // Позиционный аргумент для цветов
//               startPoints: [0.2, 0.5, 0.9], // Именованный параметр
//             ),
//             opacity: 0.7,
//           ),
//         };
//         _isLoading = false;
//       });

//       // Перемещение камеры
//       _controller?.animateCamera(
//         CameraUpdate.newLatLngZoom(_currentPosition, 12),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Ошибка: $e')),
//       );
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Тепловая карта преступлений',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color(0xFF1E88E5),
//         elevation: 4,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _currentPosition,
//               zoom: 12,
//             ),
//             onMapCreated: (GoogleMapController controller) {
//               _controller = controller;
//             },
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             heatmaps: _heatmaps,
//           ),
//           if (_isLoading)
//             Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF1E88E5),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
// }
