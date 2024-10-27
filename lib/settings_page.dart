import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ProfileDetailsPage.dart';  // استيراد الصفحة الجديدة

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isArabic = false;
  bool _isDarkMode = false;
  File? _profileImage;
  String? _adminName;
  String? _adminEmail;
  String? _adminProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    final adminProfileDoc = await FirebaseFirestore.instance.collection('admin_profile').doc('admin').get();
    if (adminProfileDoc.exists) {
      setState(() {
        _adminName = adminProfileDoc.data()!['name'];
        _adminEmail = adminProfileDoc.data()!['email'];
        _adminProfileImageUrl = adminProfileDoc.data()!['profileImageUrl'];
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('admin_profile_image.jpg');
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();
      setState(() {
        _profileImage = file;
        _adminProfileImageUrl = imageUrl;
      });
      await FirebaseFirestore.instance.collection('admin_profile').doc('admin').set({
        'name': _adminName,
        'email': _adminEmail,
        'profileImageUrl': imageUrl,
      });
    }
  }

  void _updateProfile(String name, String email, String? imageUrl) {
    setState(() {
      _adminName = name;
      _adminEmail = email;
      _adminProfileImageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF980E0E), // اللون الأول
                  Color(0xFF330000), // اللون الثاني
                ],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // تعيين لون الأيقونة إلى الأبيض
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            _isArabic ? 'الإعدادات' : 'Settings',
            style: const TextStyle(color: Colors.white), // تعيين اللون الأبيض للنص
          ),
          backgroundColor: Colors.transparent, // لجعل الخلفية شفافة
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isArabic ? 'الإعدادات' : 'Settings',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileDetailsPage(
                        adminName: _adminName,
                        adminEmail: _adminEmail,
                        adminProfileImageUrl: _adminProfileImageUrl,
                        onProfileUpdated: _updateProfile, // Pass the callback
                      ),
                    ),
                  );
                },
                child: _buildProfileSection(),
              ),
              const SizedBox(height: 20),
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : _adminProfileImageUrl != null
                ? NetworkImage(_adminProfileImageUrl!)
                : const NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _adminName ?? 'LATI',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _adminEmail ?? 'LATI@Libyan.org',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF980E0E)),
            title: Text(_isArabic ? 'تغيير اللغة' : 'Change Language'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('العربية'),
                Checkbox(
                  value: _isArabic,
                  onChanged: (bool? value) {
                    setState(() {
                      _isArabic = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Color(0xFF980E0E)),
            title: Text(_isArabic ? 'الوضع الداكن' : 'Dark Mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFF980E0E)),
            title: Text(_isArabic ? 'الإشعارات' : 'Notifications'),
            trailing: const Icon(Icons.arrow_forward),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Color(0xFF980E0E)),
            title: Text(_isArabic ? 'سياسة الخصوصية' : 'Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFF980E0E)),
            title: Text(_isArabic ? 'حول' : 'About'),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}