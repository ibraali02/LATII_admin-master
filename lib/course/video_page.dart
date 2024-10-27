import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key, required String courseToken});

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
      ),
      body: Container(
        color: Colors.white, // الخلفية البيضاء
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildVideoCard(
              context,
              'Introduction to Flutter',
              'Learn the basics of Flutter for mobile app development.',
            ),
            buildVideoCard(
              context,
              'State Management in Flutter',
              'Explore state management techniques in Flutter.',
            ),
            buildVideoCard(
              context,
              'Building Responsive UIs',
              'Design mobile apps that work on multiple screen sizes.',
            ),
            buildVideoCard(
              context,
              'Integrating APIs in Flutter',
              'Learn how to connect your app to external APIs.',
            ),
          ],
        ),
      ),
    );
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
                  // Add video play functionality here
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