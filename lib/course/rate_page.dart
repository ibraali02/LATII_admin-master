import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WeekDetailPage.dart';

class RatePage extends StatefulWidget {
  final String courseId; // استقبل courseId من الصفحة السابقة

  const RatePage({super.key, required this.courseId});

  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  final List<String> _weeks = [];
  final TextEditingController _weekTitleController = TextEditingController();
  String? _documentId;

  @override
  void initState() {
    super.initState();
    _documentId = widget.courseId; // استخدم courseId كمستند معرف
    _loadExistingWeeks(); // تحميل الأسابيع الموجودة عند بدء الصفحة
  }
  Future<void> _loadExistingWeeks() async {
    if (_documentId != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('starting_courses')
            .doc(_documentId!)
            .collection('weeks')
            .get();

        setState(() {
          _weeks.addAll(snapshot.docs.map((doc) => doc['title'] as String).toList());
        });
      } catch (e) {
        print("Error loading weeks: $e");
      }
    }
  }
  void _showAddWeekDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Week'),
          content: TextField(
            controller: _weekTitleController,
            decoration: const InputDecoration(hintText: 'Enter week title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addWeek();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addWeek() async {
    String title = _weekTitleController.text.trim();
    if (title.isNotEmpty && _documentId != null) {
      try {
        // إضافة الأسبوع الجديد إلى Firestore
        await FirebaseFirestore.instance
            .collection('starting_courses')
            .doc(_documentId!)
            .collection('weeks')
            .add({'title': title});

        setState(() {
          _weeks.add(title); // تحديث الواجهة
        });
        _weekTitleController.clear(); // مسح حقل الإدخال
      } catch (e) {
        print("Error adding week: $e");
      }
    }
  }

  void _navigateToWeekDetail(String weekTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeekDetailPage(courseId: _documentId!, weekTitle: weekTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Weeks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddWeekDialog, // فتح دايلوج لإضافة أسبوع جديد
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: _weeks.map((week) {
          return GestureDetector(
            onTap: () => _navigateToWeekDetail(week), // الانتقال إلى صفحة التفاصيل عند الضغط
            child: _buildWeekCard(week),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeekCard(String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}