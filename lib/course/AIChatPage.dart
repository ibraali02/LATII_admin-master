import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<Map<String, String>> _messages = [];
  final List<String> _courseOptions = [
    'ماجستير في الأمن السيبراني',
    'دبلوم في تطوير البرمجيات',
    'دورة في تحليل البيانات',
    'دورة في تعلم الآلة',
    'دورة في الشبكات'
  ];

  String? _selectedCourse;
  String? _aspiration;

  @override
  void initState() {
    super.initState();
    _fetchInitialMessages();
  }

  Future<void> _fetchInitialMessages() async {
    final initialMessages = await _getAIResponse("ما الكورسات التي يجب أن أدرسها؟");
    setState(() {
      _messages.addAll(initialMessages);
    });
  }

  Future<List<Map<String, String>>> _getAIResponse(String prompt) async {
    final url = Uri.parse('https://api.aimlapi.com/v1/chat/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer b0fe2018498847459625e1c33e31c730',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, String>>.from(
          data['choices'].map((choice) {
            return {
              'role': 'ai',
              'content': choice['message']['content'],
            };
          }),
        );
      } else {
        throw Exception('فشل في تحميل استجابة الذكاء الاصطناعي');
      }
    } catch (e) {
      return [{'role': 'error', 'content': "خطأ: ${e.toString()}"}];
    }
  }

  void _sendUserChoice() {
    if (_selectedCourse != null && _aspiration != null) {
      final prompt = "لقد درست $_selectedCourse وأنا أطمح أن أكون $_aspiration. ما الكورسات التي يجب أن أدرسها لتحقيق حلمي؟";
      _getAIResponse(prompt).then((newMessages) {
        setState(() {
          _messages.addAll(newMessages);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.redAccent, // خلفية حمراء للـ AppBar
      ),
      body: Container(
        color: Colors.white, // خلفية بيضاء
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat with AI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(
                    _messages[index]['content']!,
                    _messages[index]['role'] == 'user',
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('اختر الكورس الذي درسته:', style: TextStyle(fontSize: 18)),
            _buildDropdown(),
            const SizedBox(height: 20),
            Text('ما هو حلمك؟', style: TextStyle(fontSize: 18)),
            _buildTextField(),
            const SizedBox(height: 20),
            ShaderButton(
              onPressed: _sendUserChoice,
              child: const Text('إرسال', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // تغير موقع الظل
          ),
        ],
      ),
      child: DropdownButton<String>(
        hint: const Text('اختر كورس'),
        value: _selectedCourse,
        isExpanded: true,
        underline: SizedBox(), // لإخفاء الخط السفلي
        onChanged: (String? newValue) {
          setState(() {
            _selectedCourse = newValue;
          });
        },
        items: _courseOptions.map((String course) {
          return DropdownMenuItem<String>(
            value: course,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(course, style: const TextStyle(fontSize: 16)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // تغير موقع الظل
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none, // لإخفاء الحدود
          hintText: 'اكتب حلمك هنا',
          contentPadding: const EdgeInsets.all(16), // مساحة داخلية
        ),
        onChanged: (value) {
          _aspiration = value;
        },
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUserMessage) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF980E0E), // اللون الأحمر الداكن
              Color(0xFFFF5A5A), // اللون الأحمر الفاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // تغير موقع الظل
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class ShaderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ShaderButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF980E0E), // اللون الأحمر الداكن
            Color(0xFFFF5A5A), // اللون الأحمر الفاتح
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // لون خط الزر
        ),
        child: child,
      ),
    );
  }
}