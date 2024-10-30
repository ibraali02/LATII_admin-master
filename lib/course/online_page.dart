import 'package:flutter/material.dart';

class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key, required String courseToken});

  @override
  _OnlinePageState createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  void _startLiveStream() {
    // إظهار مربع حوار لتأكيد بدء البث المباشر
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start Live Stream'),
          content: const Text(
            'Please open the live stream from a desktop device connected to a camera. '
                'You will be allowed to start the stream from any device in future updates.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق مربع الحوار
              },
            ),
          ],
        );
      },
    );
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
            title: const Text('Live Course'), // تغيير عنوان الصفحة
            backgroundColor: Colors.transparent, // جعل الخلفية شفافة
            elevation: 0,
            automaticallyImplyLeading: false, // إزالة زر الرجوع
          ),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startLiveStream, // تنفيذ الوظيفة عند الضغط على الزر
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // لون الزر
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // مساحة padding
          ),
          child: const Text(
            'Start Live Stream',
            style: TextStyle(fontSize: 20, color: Colors.white), // نص الزر
          ),
        ),
      ),
    );
  }
}