import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/police_statement.dart';
import '../providers/auth_provider.dart';
import '../services/api/police_statement_service.dart';

class StatementDetailPage extends StatefulWidget {
  final int statementId;

  StatementDetailPage({required this.statementId});

  @override
  _StatementDetailPageState createState() => _StatementDetailPageState();
}

class _StatementDetailPageState extends State<StatementDetailPage> {
  PoliceStatement? statement;
  final PoliceStatementService _policeStatementService =
      PoliceStatementService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStatementDetails();
  }

  Future<void> _fetchStatementDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await _policeStatementService.getOnePoliceStatement(
          widget.statementId, authProvider.token!);

      setState(() {
        statement = PoliceStatement.fromJson(response);
      });
    } catch (e) {
      print("Ошибка загрузки заявления: $e");
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
        title: Text('Детали заявления'),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStatementDetails,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : statement == null
                ? Center(child: Text('Заявление не найдено'))
                : SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Получатель: ${statement!.recipient}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Статус: ${statement!.status}",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue)),
                        SizedBox(height: 8),
                        Text("Тип: ${statement!.typeName}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text("Описание:\n${statement!.text}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 12),
                        Text("Дата подачи: ${statement!.createdAt.toLocal()}",
                            style: TextStyle(color: Colors.grey[700])),
                        SizedBox(height: 8),
                        Text("Заявитель: ${statement!.citizenName}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
      ),
    );
  }
}
