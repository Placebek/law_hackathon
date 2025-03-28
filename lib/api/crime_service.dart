import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/crime.dart';

class PoliceStation {
  final int id;
  final String? name;
  final double latitude;
  final double longitude;
  PoliceStation(this.id,
      {this.name, required this.latitude, required this.longitude});
}

class CrimeService {
  static const String _baseUrl = 'http://192.168.43.31:8000';

  Future<List<Crime>> getCrimes({
    required double latitude,
    required double longitude,
    required double distance,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/api/crime/all_crimes?latitude=$latitude&longitude=$longitude&distance=$distance'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Crime.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка получения данных: ${response.body}');
    }
  }

  Future<List<PoliceStation>> getPoliceStations(
      {required double latitude,
      required double longitude,
      required int distance}) async {
    // Моковые данные для полицейских участков в Караганде
    return [
      PoliceStation(1,
          name: 'Центральный отдел полиции г. Караганды',
          latitude: 49.818989,
          longitude: 73.108561),
      PoliceStation(2,
          name: 'Участковый пункт полиции № 2, Центральный ОП УВД г. ',
          latitude: 49.822571,
          longitude: 73.105512),
      PoliceStation(3,
          name: 'Участковый пункт полиции № 1',
          latitude: 49.812191,
          longitude: 73.099075),
      PoliceStation(4,
          name: 'Департамент полиции Карагандинской области МВД РК',
          latitude: 49.807204,
          longitude: 73.091045),
      PoliceStation(5,
          name: 'Участковый пункт полиции № 3',
          latitude: 49.813718,
          longitude: 73.115810),
      PoliceStation(6,
          name: 'Участковый пункт полиции № 4',
          latitude: 49.804571,
          longitude: 73.100489),
      PoliceStation(7,
          name: 'Участковый пункт полиции № 5',
          latitude: 49.807204,
          longitude: 73.091045),
      PoliceStation(8,
          name: 'Участковый пункт полиции № 6',
          latitude: 49.810335,
          longitude: 73.088090),
      PoliceStation(9,
          name: 'Участковый пункт полиции № 7',
          latitude: 49.805470,
          longitude: 73.135171),
      PoliceStation(10,
          name:
              'Центральный ОП УВД города Караганды, участковый пункт полиции № 5',
          latitude: 49.785967,
          longitude: 73.110388),
      PoliceStation(11,
          name:
              'Юго-Восточный ОП УВД города Караганды, участковый пункт полиции № 9',
          latitude: 49.778863,
          longitude: 73.102395),
      PoliceStation(12,
          name:
              'Юго-Восточный ОП УВД города Караганды, участковый пункт полиции № 12',
          latitude: 49.785566,
          longitude: 73.132350),
      PoliceStation(13,
          name: 'Участковый пункт полиции № 15',
          latitude: 49.792522,
          longitude: 73.043321),
      PoliceStation(14,
          name: 'Юго-Восточный отдел полиции УП города Караганды',
          latitude: 49.769293,
          longitude: 73.156700),
      PoliceStation(15,
          name: 'Участковый пункт полиции № 11',
          latitude: 49.772783,
          longitude: 73.131431),
      PoliceStation(16,
          name: 'Участковый пункт полиции №13',
          latitude: 49.787544,
          longitude: 73.146373),
      PoliceStation(17,
          name: 'Участковый пункт полиции № 14/2',
          latitude: 49.788323,
          longitude: 73.160784),
    ];
  }
}
