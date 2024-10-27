import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'course/AIChatPage.dart';
import 'course/messages_page.dart';
import 'course/online_page.dart';
import 'course/posts_page.dart';
import 'course/rate_page.dart';
import 'course/video_page.dart';

class BookPage extends StatefulWidget {
  final String courseToken;
  final String courseName;
  final String imageUrl;
  final String description;
  final String duration;
  final String location;

  const BookPage({
    Key? key,
    required this.courseToken,
    required this.courseName,
    required this.imageUrl,
    required this.description,
    required this.duration,
    required this.location,
  }) : super(key: key);

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentPage = 'Home';
  late Widget _currentContent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
    _currentContent = PostsPage(
      courseToken: widget.courseToken,

    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: _customAppBar(context),
      ),
      body: _currentContent,
    );
  }

  Widget _customAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF980E0E),
            Color(0xFF330000),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'My Courses',
          style: GoogleFonts.poppins(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        actions: [
          _buildIconButton(Icons.home, 'Home', PostsPage(
            courseToken: widget.courseToken,

          )),
          _buildIconButton(Icons.message, 'Messages', MessagesPage(
            courseToken: widget.courseToken,

          )),
          _buildIconButton(Icons.star, 'Rate', RatePage(courseId: widget.courseToken,)),
          _buildIconButton(Icons.online_prediction, 'Online', OnlinePage(courseToken: widget.courseToken)),
          _buildIconButton(Icons.video_call, 'Video', VideoPage(courseToken: widget.courseToken)),
          _buildImageButton(),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String page, Widget content) {
    final isSelected = _currentPage == page;
    final color = isSelected ? Colors.orange : Colors.white;

    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: page,
      onPressed: () {
        setState(() {
          _currentPage = page;
          _currentContent = content;
        });
      },
    );
  }

  Widget _buildImageButton() {
    return IconButton(
      icon: Image.asset('images/img.png', height: 30),
      tooltip: 'AI',
      onPressed: () {
        setState(() {
          _currentPage = 'AI';
          _currentContent = const AIChatPage(); // تأكد من أن AIChatPage تستقبل المعطيات الصحيحة
        });
      },
    );
  }
}
