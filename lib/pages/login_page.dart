import 'package:flutter/material.dart';
import 'package:mydiary/pages/main_page.dart';
import 'package:mydiary/pages/signup_page.dart';
import 'package:mydiary/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  LoginPage({required this.isDarkMode, required this.onThemeChanged});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _auth = AuthService();
  String error = '';

  void login() async {
    try {
      final user = await _auth.signIn(
        emailController.text,
        passwordController.text,
      );
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(
              isDarkMode: widget.isDarkMode,
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => error = 'Login Failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login", style: TextStyle(fontSize: 30)),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Login")),
            Text(error, style: TextStyle(color: Colors.red)),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignupPage()),
              ),
              child: Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
