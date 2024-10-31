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
          .collection('courses')
          .where('isStarted', isEqualTo: true)
          .where('isFinished', isEqualTo: false)
          .get();
      setState(() {
        startingCourses = snapshot.docs.map((doc) {
          return {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching starting courses: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    final String courseToken = course['id'];
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

  void _finishCourse(String courseId) {
    final TextEditingController priceController = TextEditingController(); // للتحكم في حقل السعر

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد إنهاء الكورس'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هل أنت متأكد أنك تريد إنهاء هذا الكورس؟'),
              const SizedBox(height: 20),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'سعر الكورس',
                  hintText: 'أدخل سعر الكورس',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final String price = priceController.text.trim();
                if (price.isNotEmpty) {
                  try {
                    await _firestore.collection('courses').doc(courseId).update({
                      'isFinished': true,
                      'price': double.tryParse(price), // إضافة سعر الكورس
                    });
                    Navigator.of(context).pop(); // إغلاق الحوار
                    _fetchStartingCourses(); // تحديث قائمة الكورسات
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إنهاء الكورس بنجاح!')),
                    );
                  } catch (e) {
                    print("Error updating course: $e");
                    Navigator.of(context).pop(); // إغلاق الحوار
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال سعر الكورس')),
                  );
                }
              },
              child: const Text('نعم'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Starting Courses',
          style: TextStyle(color: Colors.white), // تغيير لون النص إلى الأبيض
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF980E0E), Color(0xFF330000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false, // إزالة زر الرجوع
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : startingCourses.isEmpty
          ? const Center(child: Text('لا توجد كورسات مبدوءة حالياً'))
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _navigateToCourseDetails(course),
                    child: const Text('التفاصيل'), // زر تفاصيل
                  ),
                  TextButton(
                    onPressed: () => _finishCourse(course['id']),
                    child: const Text('إنهاء الكورس'), // زر إنهاء الكورس
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}