import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/mailing_list.dart';
import '../providers/auth_provider.dart';
import '../services/api/mailing_service.dart';

class MailingListPage extends StatefulWidget {
  @override
  _MailingListPageState createState() => _MailingListPageState();
}

class _MailingListPageState extends State<MailingListPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late IOWebSocketChannel channel;
  final MailingService _mailingService = MailingService();
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/v1/ws/ws'),
    );
    print('Mailing WebSocket подключён');
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      File imageFile = File(image.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(imageBytes);
      });
    }
  }

  void submitMailing() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty) {
      MailingList mailing = MailingList(
        title: title,
        description: description,
        photo: _base64Image,
      );
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final response = await _mailingService.sendMailingList(
          mailing,
          authProvider.token!,
        );
        print('Ответ сервера: $response');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Сообщение разослано")));
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _base64Image = null;
        });
      } catch (e) {
        print('Ошибка отправки сообщения: $e');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Заполните все поля")));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    channel.sink.close();
    print('Mailing WebSocket закрыт');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Создание рассылки")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Введите название",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Введите описание",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Загрузить фото"),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: submitMailing, child: Text("Разослать")),
          ],
        ),
      ),
    );
  }
}
