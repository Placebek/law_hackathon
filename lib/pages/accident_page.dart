import 'package:flutter/material.dart';
import 'package:law_code_flutter/api/models/accident.dart';
import '/api/models/accident_type.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../api/accident_service.dart';

class AccidentPage extends StatefulWidget {
  @override
  _AccidentPageState createState() => _AccidentPageState();
}

class _AccidentPageState extends State<AccidentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();

  final AccidentService _accidentService = AccidentService();
  int? _selectedIncidentType;
  List<AccidentType> _incidentTypes = [];

  @override
  void initState() {
    super.initState();
    _loadIncidentTypes();
  }

  Future<void> _loadIncidentTypes() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<dynamic> response =
          await _accidentService.getAccidentTypes(authProvider.token!);
      setState(() {
        _incidentTypes = response.map((e) => AccidentType.fromJson(e)).toList();
      });
    } catch (e) {
      print("Ошибка загрузки типов происшествий: $e");
    }
  }

  Future<void> _submitAccident() async {
    if (_selectedIncidentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Пожалуйста, выберите тип происшествия")),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Accident newAccident = Accident(
      title: _titleController.text,
      description: _descriptionController.text,
      incidentTypeId: _selectedIncidentType!,
      photo: _photoController.text,
      video: _videoController.text,
    );

    try {
      Map<String, dynamic> response =
          await _accidentService.addAccident(newAccident, authProvider.token!);
      print("Успешно отправлено: $response");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Происшествие отправлено успешно!")),
      );
      // Очистка формы после успешной отправки
      _titleController.clear();
      _descriptionController.clear();
      _photoController.clear();
      _videoController.clear();
      setState(() {
        _selectedIncidentType = null;
      });
    } catch (e) {
      print("Ошибка при отправке: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при отправке: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Название'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Описание'),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedIncidentType,
              decoration: InputDecoration(labelText: 'Тип происшествия'),
              items: _incidentTypes
                  .map((type) =>
                      DropdownMenuItem(value: type.id, child: Text(type.name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIncidentType = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _photoController,
              decoration: InputDecoration(labelText: 'Фото (URL)'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _videoController,
              decoration: InputDecoration(labelText: 'Видео (URL)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAccident,
              child: Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _photoController.dispose();
    _videoController.dispose();
    super.dispose();
  }
}
