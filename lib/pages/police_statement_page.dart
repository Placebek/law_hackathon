import 'package:flutter/material.dart';
import 'package:law_hackathon_flutter/pages/police_statement_index_page.dart';
import 'package:provider/provider.dart';
import '../models/police_statement.dart';
import '../providers/auth_provider.dart';
import '../services/api/police_statement_service.dart';

class StatementsPage extends StatefulWidget {
  @override
  _StatementsPageState createState() => _StatementsPageState();
}

class _StatementsPageState extends State<StatementsPage> {
  List<PoliceStatement> statements = [];
  final PoliceStatementService _policeStatementService =
      PoliceStatementService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllPoliceStatements();
  }

  Future<void> _fetchAllPoliceStatements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<dynamic> response = await _policeStatementService
          .getAllPoliceStatements(authProvider.token!);

      setState(() {
        statements =
            response
                .map(
                  (e) => PoliceStatement(
                    id: e['id'],
                    recipient: e['recipient'],
                    text: e['text'],
                    createdAt: DateTime.parse(e['created_at']),
                    anonymous: e['anonymous'],
                    typeName: e['type']['type_name'],
                    status: e['status'],
                    citizenName:
                        "${e['user']['first_name']} ${e['user']['last_name']}",
                  ),
                )
                .toList();
      });
    } catch (e) {
      print("Ошибка загрузки заявлений: $e");
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
        title: Text('Заявления'),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllPoliceStatements,
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: statements.length,
                  itemBuilder: (context, index) {
                    final statement = statements[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          statement.citizenName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Тип: ${statement.typeName}\nДата: ${statement.createdAt.toLocal()}",
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StatementDetailPage(
                                    statementId: statement.id,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
