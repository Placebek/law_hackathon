import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/police_accident.dart';
import '../providers/auth_provider.dart';
import '../services/api/police_accident_service.dart';

class AccidentDetailPage extends StatefulWidget {
  final int accidentId; // Идентификатор инцидента

  AccidentDetailPage({required this.accidentId});

  @override
  _AccidentDetailPageState createState() => _AccidentDetailPageState();
}

class _AccidentDetailPageState extends State<AccidentDetailPage> {
  PoliceAccident? accident;
  final PoliceAccidentService _policeAccidentService = PoliceAccidentService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAccidentDetails();
  }

  Future<void> _fetchAccidentDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await _policeAccidentService.getOnePoliceAccident(
        widget.accidentId,
        authProvider.token!,
      );

      setState(() {
        accident = PoliceAccident.fromJson(response);
      });
    } catch (e) {
      print("Ошибка загрузки инцидента: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Детали инцидента'),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : accident == null
              ? Center(child: Text('Инцидент не найден'))
              : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Тип: ${accident!.incidentTypeName}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("Описание: ${accident!.description}"),
                    SizedBox(height: 8),
                    Text("Дата: ${accident!.createdAt.toLocal()}"),
                    SizedBox(height: 8),
                    Text(
                      "Заявитель: ${accident!.userFirstName} ${accident!.userLastName}",
                    ),
                    SizedBox(height: 16),
                    accident!.photo.isNotEmpty
                        ? Image.network(accident!.photo, fit: BoxFit.cover)
                        : Container(),
                    accident!.video.isNotEmpty
                        ? Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text("Видео: ${accident!.video}"),
                        )
                        : Container(),
                  ],
                ),
              ),
    );
  }
}
