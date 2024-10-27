import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AddJobPage extends StatefulWidget {
  const AddJobPage({Key? key}) : super(key: key);

  @override
  _AddJobPageState createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String company = '';
  String location = '';
  String description = '';
  double salary = 0;
  String requiredSkills = '';
  String responsibilities = '';
  String companyEmail = '';
  String? category;
  String? jobType;
  File? _image;
  final picker = ImagePicker();

  final List<String> jobTypes = ['Full Time', 'Part Time', 'Remote', 'Internship','Productivity-Based'];

  void _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addJobToFirestore() async {
    String? imageUrl;

    if (_image != null) {
      imageUrl = await _uploadImageToFirebaseStorage();
    }

    await FirebaseFirestore.instance.collection('new_jobs').add({
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'salary': salary,
      'requiredSkills': requiredSkills,
      'responsibilities': responsibilities,
      'companyEmail': companyEmail,
      'category': category,
      'jobType': jobType,
      'publishedDate': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
    });

    Navigator.of(context).pop();
  }

  Future<String?> _uploadImageToFirebaseStorage() async {
    try {
      final fileName = _image!.path.split('/').last;
      final storageRef = FirebaseStorage.instance.ref().child('job_images/$fileName');

      await storageRef.putFile(_image!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
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
                    'Add New Job',
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
                              label: 'Job Title',
                              onChanged: (value) {
                                title = value;
                              },
                              icon: Icons.work,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Company',
                              onChanged: (value) {
                                company = value;
                              },
                              icon: Icons.business,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Location',
                              onChanged: (value) {
                                location = value;
                              },
                              icon: Icons.location_on,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Job Description',
                              onChanged: (value) {
                                description = value;
                              },
                              icon: Icons.description,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Salary',
                              onChanged: (value) {
                                salary = double.tryParse(value) ?? 0;
                              },
                              icon: Icons.monetization_on,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Required Skills',
                              onChanged: (value) {
                                requiredSkills = value;
                              },
                              icon: Icons.checklist,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Responsibilities',
                              onChanged: (value) {
                                responsibilities = value;
                              },
                              icon: Icons.assignment,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Company Email',
                              onChanged: (value) {
                                companyEmail = value;
                              },
                              icon: Icons.email,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: jobType,
                              decoration: InputDecoration(
                                labelText: 'Job Type',
                                labelStyle: const TextStyle(color: Color(0xFF860F06)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF860F06)),
                                ),
                              ),
                              items: jobTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  jobType = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى اختيار نوع الوظيفة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
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
                                  _addJobToFirestore();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                                    'Add Job',
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
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      onChanged: onChanged,
      keyboardType: keyboardType,
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
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}