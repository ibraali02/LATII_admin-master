import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JobSeekerDetailPage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String cv;
  final String image;

  const JobSeekerDetailPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.cv,
    required this.image,
  });

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ النص إلى الحافظة!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF980E0E),
                Color(0xFF330000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipOval(
                    child: image.isNotEmpty
                        ? Image.network(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                        : const SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Name: $name',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Divider(color: Colors.grey[400]),
                const SizedBox(height: 10),
                _buildContactRow('Email', email, context),
                const SizedBox(height: 8),
                _buildContactRow('Phone', phone, context),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  'CV:',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  cv,
                  style: const TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(String label, String value, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, color: Color(0xFF980E0E)),
          onPressed: () => _copyToClipboard(context, value),
        ),
      ],
    );
  }
}