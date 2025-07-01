import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mydiary/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  ProfilePage({required this.isDarkMode, required this.onThemeChanged});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            SizedBox(height: 20),
            Text("Email: ${user?.email ?? 'Unknown'}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Confirm Logout"),
                    content: Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Logout")),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginPage(
                        isDarkMode: isDarkMode,
                        onThemeChanged: onThemeChanged,
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
