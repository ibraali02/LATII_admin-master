import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VideoPage extends StatelessWidget {
  final String courseToken; // تعريف courseToken كحقل

  const VideoPage({super.key, required this.courseToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // خلفية بيضاء للعنوان
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF980E0E), // اللون الأحمر الداكن
              Color(0xFFFF5A5A), // اللون الأحمر الفاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Mobile App Development Lectures',
            style: TextStyle(
              color: Colors.white, // النص سيأخذ لون التدرج بفضل ShaderMask
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), // لون الأيقونة أسود
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVideoDialog(context), // زر لإضافة فيديو
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // الخلفية البيضاء
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchVideos(), // جلب الفيديوهات من Firebase
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final videos = snapshot.data!;
              return ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return buildVideoCard(
                    context,
                    videos[index]['title'],
                    videos[index]['description'],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchVideos() async {
    // جلب الفيديوهات من Firestore
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('videos') // تأكد من اسم المجموعة
          .get();

      return snapshot.docs.map((doc) {
        return {
          'title': doc['title'],
          'description': doc['description'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching videos: $e");
      return [];
    }
  }

  void _showAddVideoDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final ImagePicker _picker = ImagePicker();
    File? videoFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Video'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Video Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Video Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // فتح معرض الصور لاختيار فيديو
                  final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    videoFile = File(pickedFile.path);
                  }
                },
                child: const Text('Select Video'),
              ),
            ],
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
                if (videoFile != null) {
                  _addVideo(
                    titleController.text.trim(),
                    descriptionController.text.trim(),
                    videoFile!,
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addVideo(String title, String description, File videoFile) async {
    // إضافة الفيديو إلى Firestore
    if (title.isNotEmpty && description.isNotEmpty) {
      try {
        // قم بتحميل الفيديو إلى Firebase Storage هنا
        // بعد تحميل الفيديو، يمكنك إضافة سجل الفيديو إلى Firestore
        await FirebaseFirestore.instance.collection('videos').add({
          'title': title,
          'description': description,
          // يمكنك إضافة رابط الفيديو هنا بعد التحميل
        });
      } catch (e) {
        print("Error adding video: $e");
      }
    }
  }

  Widget buildVideoCard(
      BuildContext context, String title, String description) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5, // إضافة ظل للكارد
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF980E0E), // اللون الأحمر الداكن
              Color(0xFFFF5A5A), // اللون الأحمر الفاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // النص باللون الأبيض ليكون واضحًا
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70, // لون النص الرمادي الفاتح للنصوص الثانوية
              ),
            ),
            const SizedBox(height: 10),
            Center( // توسيط الزر
              child: ElevatedButton.icon(
                onPressed: () {
                  // إضافة وظيفة تشغيل الفيديو هنا
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  'Watch Now',
                  style: TextStyle(color: Colors.white), // لون النص الأبيض
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange, // اللون البرتقالي الداكن للزر
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // زوايا منحنية للزر
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}