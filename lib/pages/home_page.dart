import 'package:flutter/material.dart';
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
    _loadData();
    _setupWebSocketListeners();
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
    _messagesBySender.clear();
    for (var message in messages) {
      final senderId = message['sender_id'].toString();
      if (!_messagesBySender.containsKey(senderId)) {
        _messagesBySender[senderId] = [];
      }
      _messagesBySender[senderId]!.add({
        'content': message['content'],
        'is_user': message['from_user'],
      });
    }
  }

  void _setupWebSocketListeners() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.policeWebSocketService != null) {
      authProvider.policeWebSocketService!.onAllMessages((messages) {
        setState(() {
          _processMessages(messages);
        });
      });
    }
    if (authProvider.chatWebSocketService != null) {
      authProvider.chatWebSocketService!.onNewMessage((data) {
        final senderId = data['fromUserId'].toString();
        setState(() {
          if (!_messagesBySender.containsKey(senderId)) {
            _messagesBySender[senderId] = [];
          }
          _messagesBySender[senderId]!.add({
            'content': data['content'],
            'is_user': data['is_user'],
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Новое сообщение от $senderId: ${data['content']}'),
          ),
        );
      });
      authProvider.chatWebSocketService!.onIncomingCall((data) async {
        await _audioPlayer.setAsset('assets/ringtone.mp3');
        await _audioPlayer.play();
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Входящий звонок'),
                content: Text('Звонит: ${data['fromUserId']}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      _audioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Text('Отклонить'),
                  ),
                  TextButton(
                    onPressed: () {
                      _audioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Text('Принять'),
                  ),
                ],
              ),
        );
      });
    }
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
                  _buildSenderList(),
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

  Widget _buildSenderList() {
    if (_messagesBySender.isEmpty) return Center(child: Text('Сообщений нет'));
    return ListView.builder(
      itemCount: _messagesBySender.keys.length,
      itemBuilder: (context, index) {
        final senderId = _messagesBySender.keys.elementAt(index);
        final lastMessage = _messagesBySender[senderId]!.last;
        final chatId =
            lastMessage['chat_id'] ?? 1; // Используем 1 по умолчанию для теста
        print('Переход в чат с senderId=$senderId, chatId=$chatId');
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
