import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api/case_service.dart';
import '../services/api/report_service.dart';
import '../services/api/message_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CaseService _caseService = CaseService();
  final ReportService _reportService = ReportService();
  final MessageService _messageService = MessageService();
  List<dynamic> _cases = [];
  List<dynamic> _reports = [];
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _setupWebSocketListeners();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      _cases = await _caseService.getCases(authProvider.token!);
      _reports = await _reportService.getReports(authProvider.token!);
      _messages = await _messageService.getMessages(authProvider.token!);
      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e')));
      setState(() => _isLoading = false);
    }
  }

  void _setupWebSocketListeners() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.webSocketService.onIncomingCall((data) {
      FlutterRingtonePlayer.playRingtone();
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Входящий звонок'),
              content: Text('Звонит: ${data['from']}'),
              actions: [
                TextButton(
                  onPressed: () {
                    FlutterRingtonePlayer.stop();
                    Navigator.pop(context);
                  },
                  child: Text('Отклонить'),
                ),
                TextButton(
                  onPressed: () {
                    FlutterRingtonePlayer.stop();
                    Navigator.pop(context);
                  },
                  child: Text('Принять'),
                ),
              ],
            ),
      );
    });

    authProvider.webSocketService.onNewMessage((data) {
      setState(() => _messages.add(data['text']));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Новое сообщение: ${data['text']}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Qamqor Police', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E88E5),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Дела'),
            Tab(text: 'Заявления'),
            Tab(text: 'Сообщения'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_cases, 'Дел нет'),
                  _buildList(_reports, 'Заявлений нет'),
                  _buildList(_messages, 'Сообщений нет'),
                ],
              ),
    );
  }

  Widget _buildList(List<dynamic> items, String emptyMessage) {
    if (items.isEmpty) return Center(child: Text(emptyMessage));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder:
          (context, index) => Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(title: Text(items[index].toString())),
          ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    FlutterRingtonePlayer.stop();
    super.dispose();
  }
}
