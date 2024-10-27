import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDetailsPage extends StatefulWidget {
  final String? adminName;
  final String? adminEmail;
  final String? adminProfileImageUrl;
  final Function(String, String, String?)? onProfileUpdated; // Callback function

  const ProfileDetailsPage({
    Key? key,
    this.adminName,
    this.adminEmail,
    this.adminProfileImageUrl,
    this.onProfileUpdated,
  }) : super(key: key);

  @override
  _ProfileDetailsPageState createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  File? _profileImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.adminName ?? '';
    _emailController.text = widget.adminEmail ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 180,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera, color: Color(0xFF9b1a1a)),
                title: Text('Take photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Add camera capture logic
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF9b1a1a)),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadProfileImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    String? imageUrl;

    if (_profileImage != null) {
      final ref = FirebaseStorage.instance.ref().child('admin_profile_image.jpg');
      await ref.putFile(_profileImage!);
      imageUrl = await ref.getDownloadURL();
    } else {
      imageUrl = widget.adminProfileImageUrl; // use the existing image URL
    }

    await FirebaseFirestore.instance.collection('admin_profile').doc('admin').set({
      'name': _nameController.text,
      'email': _emailController.text,
      'profileImageUrl': imageUrl,
    });

    // Call the callback to notify the SettingsPage
    if (widget.onProfileUpdated != null) {
      widget.onProfileUpdated!(_nameController.text, _emailController.text, imageUrl);
    }

    Navigator.pop(context); // Return to the previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF9b1a1a)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF9b1a1a),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges, // Update to save changes
            child: Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF9b1a1a),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.grey[50],
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : widget.adminProfileImageUrl != null
                            ? NetworkImage(widget.adminProfileImageUrl!)
                            : null,
                        child: _profileImage == null && widget.adminProfileImageUrl == null
                            ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF9b1a1a),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Name'),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Enter your name',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('Email'),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF9b1a1a)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}