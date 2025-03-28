import 'package:flutter/material.dart';
import 'package:law_code_flutter/api/auth_service.dart';
import 'package:law_code_flutter/api/models/verification_request.dart';
import 'package:law_code_flutter/api/models/register_request.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _uinController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  int _step = 1;
  String? _email;

  void _nextStep() async {
    try {
      if (_step == 1) {
        await _authService.sendEmail(_emailController.text);
        setState(() {
          _email = _emailController.text;
          _step = 2;
        });
      } else if (_step == 2) {
        final request =
            VerificationRequest(email: _email!, code: _codeController.text);
        await _authService.verifyCode(request);
        setState(() {
          _step = 3;
        });
      } else if (_step == 3) {
        final request = RegisterRequest(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          uin: _uinController.text,
          email: _email!,
          phoneNumber: _phoneController.text,
          password: _passwordController.text,
        );
        final response = await _authService.register(request);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Регистрация успешна!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Регистрация', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1E88E5),
          elevation: 4,
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: _buildStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_step == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _nextStep,
            child: Text('Отправить код'),
          ),
        ],
      );
    } else if (_step == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Код отправлен на $_email', style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(labelText: 'Код (6 символов)'),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _nextStep,
            child: Text('Подтвердить'),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Имя'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Фамилия'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _uinController,
              decoration: InputDecoration(labelText: 'ИИН'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Номер телефона'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextStep,
              child: Text('Зарегистрироваться'),
            ),
          ],
        ),
      );
    }
  }
}
