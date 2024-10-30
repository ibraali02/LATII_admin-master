import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'AddContentPage.dart';

class PostsPage extends StatefulWidget {
  final String courseToken;

  const PostsPage({
    super.key,
    required this.courseToken,
  });

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  bool isLoading = true;
  List<DocumentSnapshot> posts = [];

  // المتغيرات اللازمة للقسم الجديد
  DateTime? startDate; // تاريخ بدء الدورة
  String? duration; // مدة الدورة
  String? imageUrl; // رابط الصورة

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // جلب البوستات عند تهيئة الصفحة
    _fetchCourseDetails(); // جلب تفاصيل الدورة
  }

  Future<void> _fetchPosts() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseToken)
          .collection('contents') // استخدام المحتوى من المجموعة الفرعية
          .get();

      setState(() {
        posts = snapshot.docs; // تخزين البوستات
        isLoading = false; // تغيير حالة التحميل
      });
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  // دالة لجلب تفاصيل الدورة
  Future<void> _fetchCourseDetails() async {
    try {
      DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseToken)
          .get();

      setState(() {
        startDate = (courseSnapshot['startDate'] as Timestamp).toDate(); // تحويل Timestamp إلى DateTime
        duration = courseSnapshot['duration'];
        imageUrl = courseSnapshot['imageUrl'];
      });
    } catch (e) {
      print("Error fetching course details: $e");
    }
  }

  Widget _continueLearningSection() {
    if (startDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final difference = now.difference(startDate!);
    final months = int.parse(duration!.split(' ')[0]);
    final totalDuration = Duration(days: months * 30);
    final completedPercentage = (difference.inDays / totalDuration.inDays).clamp(0, 1);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            imageUrl != null
                ? Image.network(imageUrl!, height: 60, width: 60, fit: BoxFit.cover)
                : const SizedBox(height: 60, width: 60),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('APP', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    "Course Title", // يمكنك تعديل هذا ليتناسب مع بيانات الدورة
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(5),
                    value: completedPercentage.toDouble(),
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC02626)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(completedPercentage * 100).toStringAsFixed(0)}% Complete',
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Contents"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _continueLearningSection(), // إضافة قسم "استمر في التعلم"
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  var postData = posts[index].data() as Map<String, dynamic>;

                  return _buildPostCard(
                    context,
                    title: postData['title'] ?? 'No Title',
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

  Widget _buildPostCard(BuildContext context, {required String title, required String description}) {
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
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}