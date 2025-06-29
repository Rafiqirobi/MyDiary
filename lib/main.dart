import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mydiary/pages/login_page.dart';
import 'package:mydiary/pages/home_page.dart';
import 'package:mydiary/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init(); // Firebase Cloud Messaging init
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Diary',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
