import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api/case_service.dart';
import '../services/api/report_service.dart';
import 'package:just_audio/just_audio.dart';
import 'police_chat_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CaseService _caseService = CaseService();
  final ReportService _reportService = ReportService();
  List<dynamic> _cases = [];
  List<dynamic> _reports = [];
  Map<String, List<Map<String, dynamic>>> _messagesBySender = {};
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_isLoading && authProvider.token != null) {
      _loadData();
    } else if (authProvider.token == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пожалуйста, войдите в систему')),
        );
      });
    }
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      _cases = await _caseService.getCases(authProvider.token!);
      _reports = await _reportService.getReports(authProvider.token!);
      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e')));
      setState(() => _isLoading = false);
    }
  }

  void _processMessages(List<Map<String, dynamic>> messages) {
    final authProvider = Provider.of<AuthProvider>(context);
    _messagesBySender.clear();
    for (var message in messages) {
      final senderId =
          message['sender_id']?.toString() ?? message['fromUserId']?.toString();
      if (senderId != null) {
        if (!_messagesBySender.containsKey(senderId)) {
          _messagesBySender[senderId] = [];
        }
        _messagesBySender[senderId]!.add({
          'content': message['content'],
          'is_user':
              message['is_user'] ??
              (message['fromUserId'] == authProvider.username),
          'chat_id': message['chat_id'],
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        _processMessages(
          authProvider.allMessages,
        ); // Используем сообщения из AuthProvider
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
                      _buildSenderList(),
                    ],
                  ),
        );
      },
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

  Widget _buildSenderList() {
    if (_messagesBySender.isEmpty) return Center(child: Text('Сообщений нет'));
    return ListView.builder(
      itemCount: _messagesBySender.keys.length,
      itemBuilder: (context, index) {
        final senderId = _messagesBySender.keys.elementAt(index);
        final lastMessage = _messagesBySender[senderId]!.last;
        final chatId = lastMessage['chat_id'] ?? 1;
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            title: Text('Житель $senderId'),
            subtitle: Text(lastMessage['content']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PoliceChatPage(senderId: senderId, chatId: chatId),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
