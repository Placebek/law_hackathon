import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final ImagePicker _picker = ImagePicker();
  File? _photoFile;

  final AccidentService _accidentService = AccidentService();
  int? _selectedIncidentType;
  List<AccidentType> _incidentTypes = [];

  @override
  void initState() {
    super.initState();
    _loadIncidentTypes();
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _photoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _loadIncidentTypes() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<dynamic> response =
          await _accidentService.getAccidentTypes(authProvider.token!);
      print("Типы происшествий: $response");
      setState(() {
        _incidentTypes = response.map((e) => AccidentType.fromJson(e)).toList();
      });
    } catch (e) {
      print("Ошибка загрузки типов происшествий: $e");
    }
  }

  Future<void> _submitAccident() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Создаем объект Accident
    Accident newAccident = Accident(
      title: _titleController.text,
      description: _descriptionController.text,
      incidentTypeId: _selectedIncidentType!,
      photo: _photoFile,
      video: _videoController.text,
    );

    try {
      Map<String, dynamic> response =
          await _accidentService.addAccident(newAccident, authProvider.token!);
      print("Успешно отправлено: $response");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Происшествие отправлено успешно!")),
      );
    } catch (e) {
      print("Ошибка при отправке: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при отправке!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
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
                _selectedIncidentType = value!;
              });
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _takePhoto,
            child: Text("Сделать фото"),
          ),
          if (_photoFile != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("Фото прикреплено"),
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
    );
  }
}
