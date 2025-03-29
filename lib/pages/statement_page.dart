import 'package:flutter/material.dart';

class StatementPage extends StatefulWidget {
  @override
  _StatementPageState createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  int _selectedType = 0;
  bool _isAnonymous = false;

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
            value: _selectedType,
            decoration: InputDecoration(labelText: 'Тип заявления'),
            items: [
              DropdownMenuItem(value: 0, child: Text('Жалоба')),
              DropdownMenuItem(value: 1, child: Text('Предложение')),
              DropdownMenuItem(value: 2, child: Text('Запрос информации')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
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
            onPressed: () {
              Map<String, dynamic> statementData = {
                "recipient": _recipientController.text,
                "text": _textController.text,
                "type_id": _selectedType,
                "anonymous": _isAnonymous
              };
              print(statementData);
            },
            child: Text('Отправить'),
          ),
        ],
      ),
    );
  }
}
