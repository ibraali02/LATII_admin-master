import 'package:flutter/material.dart';

class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key, required String courseToken});

  @override
  _OnlinePageState createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  final List<String> _comments = [
    'Ibrahim Al-Sanousi: This is a great session!',
    'Ali Ayad: I learned a lot from this course.',
  ];
  final TextEditingController _commentController = TextEditingController();

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add('You: ${_commentController.text}');
        _commentController.clear(); // مسح حقل الإدخال
      });
    }
  }

  void _startLiveStream() {
    // هنا يمكنك إضافة الوظيفة لبدء البث المباشر
    print('Starting live stream...'); // مثال على وظيفة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF980E0E), // اللون الأحمر الداكن
              Color(0xFFFF5A5A), // اللون الأحمر الفاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: AppBar(
            title: const Text('Online'),
            backgroundColor: Colors.transparent, // جعل الخلفية شفافة
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildLiveStream(), // استبدال الفيديو بالصورة
                const SizedBox(height: 20),
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._comments.map((comment) => _buildCommentCard(comment)).toList(),
              ],
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildLiveStream() {
    return GestureDetector(
      onTap: _startLiveStream, // عند الضغط على الصورة، يمكنك بدء البث المباشر
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'images/img_3.png', // استخدام مسار الصورة
                fit: BoxFit.cover,
                height: 200, // ضبط ارتفاع الصورة
                width: double.infinity, // ضبط العرض ليملأ العنصر
              ),
              Positioned(
                child: ElevatedButton(
                  onPressed: _startLiveStream, // تنفيذ الوظيفة عند الضغط على الزر
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // لون الزر
                    shape: const CircleBorder(), // شكل دائري
                    padding: const EdgeInsets.all(20), // مساحة padding
                  ),
                  child: const Icon(
                    Icons.play_arrow, // رمز التشغيل
                    size: 30,
                    color: Colors.white, // لون أيقونة التشغيل
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCard(String comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF980E0E), // اللون الأحمر الداكن
              Color(0xFFFF5A5A), // اللون الأحمر الفاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.0), // إضافة زوايا دائرية
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            comment,
            style: const TextStyle(color: Colors.white), // لون النص أبيض
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _addComment,
          ),
        ],
      ),
    );
  }
}