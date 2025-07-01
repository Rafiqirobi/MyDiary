import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mydiary/pages/login_page.dart';
import 'package:mydiary/pages/main_page.dart';
import 'package:mydiary/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

  MyApp({super.key}) {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = prefs.getBool('darkMode') ?? false;
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    isDarkModeNotifier.value = isDark;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'My Diary',
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          debugShowCheckedModeBanner: false,
          home: FirebaseAuth.instance.currentUser == null
          ? LoginPage(
              isDarkMode: isDark,
              onThemeChanged: _toggleTheme,
            )
          : MainPage(
              isDarkMode: isDark,
              onThemeChanged: _toggleTheme,
            ),
        );
      },
    );
  }
}
