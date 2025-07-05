import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mydiary/pages/login_page.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  ProfilePage({required this.isDarkMode, required this.onThemeChanged});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  String? username;
  String? gender;
  DateTime? dob;
  File? _image;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
      final savedGender = prefs.getString('gender');
      gender = ['♂️ Male', '♀️ Female', '⚧️ Other'].contains(savedGender) ? savedGender : '♂️ Male';
      final dobString = prefs.getString('dob');
      if (dobString != null) dob = DateTime.tryParse(dobString);
      final path = prefs.getString('profileImagePath');
      if (path != null) _image = File(path);
    });
  }

  int? calculateAge() {
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob!.year;
    if (now.month < dob!.month || (now.month == dob!.month && now.day < dob!.day)) {
      age--;
    }
    return age;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', picked.path);
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> showEditProfileDialog() async {
    final nameController = TextEditingController(text: username);
    String selectedGender = gender ?? '♂️ Male';
    DateTime selectedDob = dob ?? DateTime(2000);

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            title: Text('Edit Profile'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Gender: "),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedGender,
                        items: ['♂️ Male', '♀️ Female', '⚧️ Other']
                            .map((g) => DropdownMenuItem<String>(
                                  value: g,
                                  child: Text(g),
                                ))
                            .toList(),
                        onChanged: (newGender) {
                          if (newGender != null) {
                            setModalState(() => selectedGender = newGender);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("DOB: ${DateFormat('d MMMM yyyy').format(selectedDob)}"),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDob,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDob = picked);
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('username', nameController.text.trim());
                  await prefs.setString('gender', selectedGender);
                  await prefs.setString('dob', selectedDob.toIso8601String());

                  setState(() {
                    username = nameController.text.trim();
                    gender = selectedGender;
                    dob = selectedDob;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Profile updated')),
                  );
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? age = calculateAge();

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (Theme.of(context).brightness == Brightness.light)
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null ? Icon(Icons.person, size: 50) : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    username ?? '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  _buildInfoTile("Gender", gender ?? ''),
                  _buildInfoTile("Date of Birth", dob != null ? DateFormat('d MMMM yyyy').format(dob!) : 'Not set'),
                  _buildInfoTile("Age", age?.toString() ?? 'Unknown'),
                ],
              ),
            ), // Profile card with avatar and user info
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
              ),
              onPressed: showEditProfileDialog,
            ), // Edit profile button
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
                ); // Show confirmation dialog

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginPage(
                        isDarkMode: widget.isDarkMode,
                        onThemeChanged: widget.onThemeChanged,
                      ),
                    ),
                    (route) => false,
                  ); // Clear navigation stack
                }
              },
            ), // Logout button
          ], 
        ),
      ), // Scaffold body
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(value, style: TextStyle(fontSize: 16)),
      leading: Icon(_getIconForField(title)),
    );
  } // Builds a tile for displaying user info

  IconData _getIconForField(String field) {
    switch (field) {
      case 'Gender':
        return Icons.wc;
      case 'Date of Birth':
        return Icons.calendar_today;
      case 'Age':
        return Icons.cake;
      default:
        return Icons.info_outline;
    }
  } // Helper method to get icon based on field name
}
