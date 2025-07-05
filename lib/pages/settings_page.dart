import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  SettingsPage({required this.isDarkMode, required this.onThemeChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
    isDark = widget.isDarkMode;
  }

  void toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    widget.onThemeChanged(value);
    setState(() => isDark = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sectionTitleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: colorScheme.primary,
    );

    BoxDecoration boxStyle = BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        if (!theme.brightness.toString().contains('dark'))
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
      ], // Shadow for light mode
    ); 

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Appearance", style: sectionTitleStyle),
          SizedBox(height: 8),
          Container(
            decoration: boxStyle,
            child: SwitchListTile(
              title: Text("Dark Mode"),
              secondary: Icon(Icons.dark_mode),
              value: isDark,
              onChanged: toggleTheme,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ), // Dark mode toggle
          SizedBox(height: 20),
          Text("Reminders", style: sectionTitleStyle),
          SizedBox(height: 8),
          Container(
            decoration: boxStyle,
            child: ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Daily Entry Reminder"),
              subtitle: Text("Set a notification to write a daily diary"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement notification setup
              },
            ),
          ),
          SizedBox(height: 20),
          Text("General", style: sectionTitleStyle),
          SizedBox(height: 8),
          Container(
            decoration: boxStyle,
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "My Diary",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2025 Rafiqi",
                );
              },
            ),
          ), // About section
        ],
      ),
    );
  }
}
