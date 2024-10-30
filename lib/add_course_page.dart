import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({Key? key}) : super(key: key);

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String? category;
  String duration = '';
  String price = ''; // إضافة متغير السعر
  File? _image;
  final picker = ImagePicker();

  final List<String> categories = [
    'Programming',
    'Design',
    'Cybersecurity',
    'App Development'
  ];

  void _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addCourseToFirestore() async {
    String? imageUrl;

    if (_image != null) {
      imageUrl = await _uploadImageToFirebaseStorage();
      if (imageUrl == null) {
        _showErrorDialog('فشل تحميل الصورة');
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('courses').add({
        'title': title,
        'description': description,
        'category': category,
        'location': 'Libya',
        'publishedDate': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'duration': duration,
        'price': price, // إضافة السعر إلى البيانات المرسلة
        'isStarted': false, // تعيين isStarted إلى false
        'isFinished': false, // تعيين isFinished إلى false
      });
      Navigator.of(context).pop(true);
    } catch (e) {
      _showErrorDialog('فشل إضافة الدورة: $e');
    }
  }

  Future<String?> _uploadImageToFirebaseStorage() async {
    if (_image == null) return null;

    try {
      final fileName = _image!.path.split('/').last;
      final storageRef = FirebaseStorage.instance.ref().child('courses/$fileName');
      await storageRef.putFile(_image!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('موافق'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF980E0E),
              Color(0xFF330000),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Add New Course',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              label: 'Course Title',
                              onChanged: (value) {
                                title = value;
                              },
                              icon: Icons.book,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Course Description',
                              onChanged: (value) {
                                description = value;
                              },
                              icon: Icons.description,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Course Duration (in Months)',
                              onChanged: (value) {
                                duration = value;
                              },
                              icon: Icons.timer,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Course Price',
                              onChanged: (value) {
                                price = value; // تحديث السعر
                              },
                              icon: Icons.attach_money,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: category,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                labelStyle: const TextStyle(color: Color(0xFF860F06)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF860F06)),
                                ),
                              ),
                              items: categories.map((String cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  category = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار فئة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _selectImage,
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF980E0E),
                                      Color(0xFF330000),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Select Image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_image != null) ...[
                              const SizedBox(height: 10),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF980E0E),
                                        Color(0xFF330000).withOpacity(0.5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _image!,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _addCourseToFirestore();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide.none,
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF980E0E),
                                      Color(0xFF330000),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 88.0,
                                    minHeight: 48.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Add Course',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF860F06)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF860F06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF860F06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF860F06)),
        ),
        prefixIcon: Icon(icon, color: Color(0xFF860F06)),
      ),
      style: const TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال $label';
        }
        return null;
      },
    );
  }
}