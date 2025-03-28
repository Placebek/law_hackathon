import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'register_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Профиль',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5).withOpacity(0.1), Colors.white],
          ),
        ),
        child: Center(
          child: authProvider.isAuthenticated
              ? _buildAuthenticatedView(context, authProvider)
              : _buildUnauthenticatedView(context),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(
      BuildContext context, AuthProvider authProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF1E88E5),
          child: Text(
            authProvider.user!.name[0].toUpperCase(),
            style: TextStyle(fontSize: 40, color: Colors.white),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Привет, ${authProvider.user!.name}!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        SizedBox(height: 30),
        _buildStyledButton(
          context: context,
          text: 'История обращений',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryPage()),
            );
          },
        ),
        SizedBox(height: 20),
        _buildStyledButton(
          context: context,
          text: 'Выйти',
          onPressed: () => authProvider.logout(),
          color: Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Добро пожаловать!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Войдите или зарегистрируйтесь',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        SizedBox(height: 30),
        _buildStyledButton(
          context: context,
          text: 'Регистрация',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
        ),
        SizedBox(height: 20),
        _buildStyledButton(
          context: context,
          text: 'Вход',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStyledButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: Colors.black26,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'История обращений',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: 2,
          itemBuilder: (context, index) {
            final appeals = [
              'Обращение 1 - 01.01.2023',
              'Обращение 2 - 02.01.2023',
            ];
            return Card(
              elevation: 3,
              margin: EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.history, color: Color(0xFF1E88E5)),
                title: Text(
                  appeals[index],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing:
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Вы выбрали ${appeals[index]}')),
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
