import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mydiary/services/auth_service.dart';
import 'package:mydiary/pages/login_page.dart';
import 'package:mydiary/pages/main_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool _obscurePassword = true;
  String error = '';

  Future<void> signup() async {
    try {
      final user = await _auth.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        // Store username in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', usernameController.text.trim());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(isDarkMode: false, onThemeChanged: (_) {}),
          ),
        );
      }
    } catch (e) {
      setState(() => error = 'Signup failed. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.person_add, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text("Create Your Account", style: theme.textTheme.headlineMedium),
              const SizedBox(height: 32),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: signup,
                icon: Icon(Icons.check),
                label: Text("Sign Up"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              if (error.isNotEmpty)
                Text(error, style: TextStyle(color: Colors.red)),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginPage(isDarkMode: false, onThemeChanged: (_) {}),
                    ),
                  );
                },
                child: Text("Already have an account? Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
