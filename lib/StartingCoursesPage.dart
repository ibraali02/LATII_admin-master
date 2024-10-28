import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled9/book_page.dart';

class StartingCoursesPage extends StatefulWidget {
  const StartingCoursesPage({Key? key}) : super(key: key);

  @override
  _StartingCoursesPageState createState() => _StartingCoursesPageState();
}

class _StartingCoursesPageState extends State<StartingCoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> startingCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStartingCourses();
  }

  Future<void> _fetchStartingCourses() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('courses') // تأكد من أن اسم المجموعة صحيح
          .where('isStarted', isEqualTo: true) // تحقق من حقل isStarted
          .get();
      setState(() {
        startingCourses = snapshot.docs.map((doc) {
          return {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id, // إضافة معرف الوثيقة
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching starting courses: $e");
    } finally {
      setState(() {
        isLoading = false; // إنهاء حالة التحميل
      });
    }
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    // تحقق من الحقول المطلوبة
    final String courseToken = course['id']; // استخدم معرّف الوثيقة
    final String courseName = course['title'] ?? 'Untitled Course';
    final String imageUrl = course['image'] ?? '';
    final String description = course['description'] ?? 'No description available';
    final String duration = course['duration'] ?? '0 hours';
    final String location = course['location'] ?? 'Online';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookPage(
          courseToken: courseToken,
          courseName: courseName,
          imageUrl: imageUrl,
          description: description,
          duration: duration,
          location: location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starting Courses'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF980E0E), Color(0xFF330000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: startingCourses.length,
        itemBuilder: (context, index) {
          final course = startingCourses[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(course['title'] ?? 'Untitled Course'),
              subtitle: Text(course['description'] ?? 'No description available'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _navigateToCourseDetails(course),
            ),
          );
        },
      ),
    );
  }
}