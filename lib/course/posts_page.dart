import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'AddContentPage.dart';

class PostsPage extends StatefulWidget {
  final String courseToken; // التوكن للكورس

  const PostsPage({
    super.key,
    required this.courseToken,
  });

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  String? description; // لتخزين وصف الكورس
  String? duration; // لتخزين مدة الكورس
  String? location; // لتخزين موقع الكورس
  DateTime? startDate; // لتخزين تاريخ البدء
  String? title; // لتخزين عنوان الكورس
  String? imageUrl; // لتخزين رابط الصورة
  bool isLoading = true;

  List<DocumentSnapshot> posts = []; // لتخزين البوستات

  @override
  void initState() {
    super.initState();
    _fetchCourseData(); // جلب بيانات الكورس عند تهيئة الصفحة
    _fetchPosts(); // جلب البوستات
  }

  Future<void> _fetchCourseData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('starting_courses')
          .where('courseId', isEqualTo: widget.courseToken)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          description = data['description'];
          duration = data['duration'];
          location = data['location'];
          startDate = (data['startedAt'] as Timestamp).toDate(); // تحويل Timestamp إلى DateTime
          title = data['title'];
          imageUrl = data['image'];
          isLoading = false; // تغيير حالة التحميل
        });
      }
    } catch (e) {
      print("Error fetching course data: $e");
    }
  }

  Future<void> _fetchPosts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('course_contents')
          .where('courseId', isEqualTo: widget.courseToken) // استخدام courseToken لجلب البوستات
          .get();

      setState(() {
        posts = snapshot.docs; // تخزين البوستات
      });
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator()); // عرض دائرة التحميل
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Course Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _continueLearningSection(), // قسم متابعة التعلم
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  var postData = posts[index].data() as Map<String, dynamic>;

                  // تحقق من نوع الحقول
                  String date = '';
                  String time = '';

                  if (postData['startDate'] is Timestamp) {
                    date = DateFormat('yyyy-MM-dd').format((postData['startDate'] as Timestamp).toDate());
                  } else if (postData['startDate'] is String) {
                    date = postData['startDate']; // إذا كانت نصًا، استخدمها مباشرة
                  }

                  if (postData['startTime'] is Timestamp) {
                    time = DateFormat.jm().format((postData['startTime'] as Timestamp).toDate());
                  } else if (postData['startTime'] is String) {
                    time = postData['startTime']; // إذا كانت نصًا، استخدمها مباشرة
                  }

                  return _buildPostCard(
                    context,
                    title: postData['title'] ?? 'No Title',
                    date: date,
                    time: time,
                    description: postData['description'] ?? 'No Description',
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddContentPage(courseToken: widget.courseToken),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF980E0E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add Content'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(
      BuildContext context, {
        required String title,
        required String date,
        required String time,
        required String description,
      }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF980E0E),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registered for the workshop!')),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF980E0E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Register Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _continueLearningSection() {
    if (startDate == null) return const SizedBox.shrink(); // إذا لم يكن تاريخ البدء متاحًا

    // حساب الوقت المنقضي
    final now = DateTime.now();
    final difference = now.difference(startDate!);
    final months = int.parse(duration!.split(' ')[0]); // استخراج عدد الأشهر
    final totalDuration = Duration(days: months * 30); // تحويل الأشهر إلى أيام
    final completedPercentage = (difference.inDays / totalDuration.inDays).clamp(0, 1); // تأكد من أن النسبة بين 0 و 1

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            imageUrl != null
                ? Image.network(imageUrl!, height: 60, width: 60, fit: BoxFit.cover)
                : const SizedBox(height: 60, width: 60), // صورة افتراضية إذا كانت null
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('APP', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    title ?? "Course Title",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(5),
                    value: completedPercentage.toDouble(), // تحويل إلى double
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC02626)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(completedPercentage * 100).toStringAsFixed(0)}% مكتمل', // عرض النسبة المئوية المكتملة
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}