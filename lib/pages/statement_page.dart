import 'package:flutter/material.dart';
import '/api/statement_service.dart';
import 'package:provider/provider.dart';
import '../api/models/statement.dart';
import '../api/models/statement_type.dart';
import '../providers/auth_provider.dart';

class StatementPage extends StatefulWidget {
  @override
  _StatementPageState createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  bool _isAnonymous = false;

  final StatementService _statementService = StatementService();
  int? _selectedStatementType;
  List<StatementType> _statementTypes = [];

  Future<void> _loadStatementTypes() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<dynamic> response =
          await _statementService.getStatementTypes(authProvider.token!);
      setState(() {
        _statementTypes =
            response.map((e) => StatementType.fromJson(e)).toList();
      });
    } catch (e) {
      print("Ошибка загрузки типов происшествий: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStatementTypes();
  }

  Future<void> _submitStatement() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Создаем объект Accident
    Statement newStatement = Statement(
      anonymous: _isAnonymous,
      recipient: _recipientController.text,
      statementTypeId: _selectedStatementType!,
      text: _textController.text,
    );

    try {
      Map<String, dynamic> response = await _statementService.addStatement(
          newStatement, authProvider.token!);
      print("Успешно отправлено: $response");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Заявление отправлено успешно!")),
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
            controller: _recipientController,
            decoration: InputDecoration(labelText: 'Получатель'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _textController,
            decoration: InputDecoration(labelText: 'Текст заявления'),
            maxLines: 5,
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _selectedStatementType,
            decoration: InputDecoration(labelText: 'Тип происшествия'),
            items: _statementTypes
                .map((type) =>
                    DropdownMenuItem(value: type.id, child: Text(type.name)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatementType = value!;
              });
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value!;
                  });
                },
              ),
              Text('Анонимно')
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitStatement,
            child: Text('Отправить'),
          ),
        ],
      ),
    );
  }
}
