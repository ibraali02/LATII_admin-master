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

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // جلب البوستات عند تهيئة الصفحة
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