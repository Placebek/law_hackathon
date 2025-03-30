import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/police_accident.dart';
import '../providers/auth_provider.dart';
import '../services/api/police_accident_service.dart';
import 'police_accident_index_page.dart';

class AccidentsPage extends StatefulWidget {
  @override
  _AccidentsPageState createState() => _AccidentsPageState();
}

class _AccidentsPageState extends State<AccidentsPage> {
  List<PoliceAccident> accidents = [];
  final PoliceAccidentService _policeAccidentService = PoliceAccidentService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllPoliceAccidents();
  }

  Future<void> _fetchAllPoliceAccidents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      List<dynamic> response = await _policeAccidentService
          .getAllPoliceAccidents(authProvider.token!);

      setState(() {
        accidents = response.map((e) => PoliceAccident.fromJson(e)).toList();
      });
    } catch (e) {
      print("Ошибка загрузки инцидентов: $e");
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
        title: Text('Инциденты'),
        backgroundColor: Color(0xFF1E88E5),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllPoliceAccidents,
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: accidents.length,
                  itemBuilder: (context, index) {
                    final accident = accidents[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          "${accident.userFirstName} ${accident.userLastName}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Тип: ${accident.incidentTypeName}\nДата: ${accident.createdAt.toLocal()}",
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AccidentDetailPage(
                                    accidentId: accident.id,
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
