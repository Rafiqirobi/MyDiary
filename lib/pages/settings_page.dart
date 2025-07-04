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
    final Color primaryColor = isDark ? Colors.tealAccent : Color(0xFF87CEEB);
    final TextStyle sectionTitleStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Appearance", style: sectionTitleStyle),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: SwitchListTile(
              title: Text("Dark Mode"),
              secondary: Icon(Icons.dark_mode),
              value: isDark,
              onChanged: toggleTheme,
            ),
          ),
          SizedBox(height: 20),
          Text("Reminders", style: sectionTitleStyle),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Daily Entry Reminder"),
                  subtitle: Text("Set a notification to write a daily diary"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to reminder settings (to implement)
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text("General", style: sectionTitleStyle),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.backup),
                  title: Text("Backup & Restore"),
                  subtitle: Text("Backup your diary to the cloud or restore it"),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Implement backup/restore logic
                  },
                ),
                Divider(height: 1),
                ListTile(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
