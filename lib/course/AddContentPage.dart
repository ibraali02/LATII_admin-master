import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddContentPage extends StatefulWidget {
  final String courseToken; // استلام التوكن

  const AddContentPage({Key? key, required this.courseToken}) : super(key: key);

  @override
  _AddContentPageState createState() => _AddContentPageState();
}

class _AddContentPageState extends State<AddContentPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String? selectedType = 'Workshop'; // Default to Workshop
  DateTime? startDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final List<String> contentTypes = ['Workshop', 'Announcement'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Content'),
        backgroundColor: const Color(0xFF980E0E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                label: 'Content Title',
                onChanged: (value) {
                  title = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: contentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedType = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (selectedType == 'Workshop') ...[
                _buildDateField(context),
                const SizedBox(height: 16),
                _buildTimeField(context, isStart: true),
                const SizedBox(height: 16),
                _buildTimeField(context, isStart: false),
              ],
              if (selectedType == 'Announcement') ...[
                _buildTextField(
                  label: 'Content Description',
                  onChanged: (value) {
                    description = value;
                  },
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addContent(widget.courseToken); // إضافة المحتوى إلى Firestore
                  }
                },
                child: const Text('Add Content'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addContent(String courseToken) async {
    try {
      // إعداد البيانات التي ستتم إضافتها
      final contentData = {
        'title': title,
        'description': description,
        'type': selectedType,
        'startDate': startDate,
        'startTime': startTime?.format(context),
        'endTime': endTime?.format(context),
        'courseId': courseToken, // تخزين courseToken
      };

      // إضافة البيانات إلى Firestore
      await FirebaseFirestore.instance.collection('course_contents').add(contentData);

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content added successfully!')),
      );

      // العودة إلى الصفحة السابقة
      Navigator.pop(context);
    } catch (e) {
      print("Error adding content: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add content.')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Workshop Date',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                startDate = pickedDate;
              });
            }
          },
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: startDate != null ? "${startDate!.toLocal()}".split(' ')[0] : '',
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, {required bool isStart}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: isStart ? 'Start Time' : 'End Time',
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: isStart ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now()),
            );
            if (pickedTime != null) {
              setState(() {
                if (isStart) {
                  startTime = pickedTime;
                } else {
                  endTime = pickedTime;
                }
              });
            }
          },
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: isStart
            ? (startTime != null ? startTime!.format(context) : '')
            : (endTime != null ? endTime!.format(context) : ''),
      ),
    );
  }
}