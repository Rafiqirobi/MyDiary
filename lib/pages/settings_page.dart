import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool('darkMode') ?? false);
  }

  void toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Dark Mode"),
            value: isDarkMode,
            onChanged: toggleTheme,
          ),
        ],
      ),
    );
  }
}
