import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDetailsPage extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String? imageUrl;

  const CourseDetailsPage({
    Key? key,
    required this.courseId,
    required this.courseName,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF980E0E),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          courseName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 50),
                              ),
                            );
                          },
                        )
                            : Container(
                          color: Colors.grey,
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Accepted Students'),
                      _buildAcceptedStudentsList(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Registration Requests'),
                      _buildRegistrationRequestsList(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Previous Videos'),
                      _buildPreviousVideosList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAcceptedStudentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('accepted_students')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading accepted students'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No students accepted', style: TextStyle(color: Colors.white)));
        }

        final acceptedStudents = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: acceptedStudents.length,
          itemBuilder: (context, index) {
            final student = acceptedStudents[index].data() as Map<String, dynamic>;
            return _buildStudentCard(student);
          },
        );
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        title: Text(
          'Name: ${student['fullName']?.toString() ?? 'No Name'}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Email: ${student['email']?.toString() ?? 'No Email'}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteAcceptedStudent(student['id']), // حذف الطالب
        ),
      ),
    );
  }

  Future<void> _deleteAcceptedStudent(String studentId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('accepted_students')
        .doc(studentId)
        .delete(); // حذف الطالب من المقبولين
  }

  Widget _buildRegistrationRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('registration_requests')
          .where('courseId', isEqualTo: courseId) // تصفية الطلبات بناءً على courseId
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading registration requests'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No registration requests available', style: TextStyle(color: Colors.white)));
        }

        final registrationRequests = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: registrationRequests.length,
          itemBuilder: (context, index) {
            final request = registrationRequests[index].data() as Map<String, dynamic>;
            return _buildRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        title: Text(
          'Name: ${request['fullName']?.toString() ?? 'No Name'}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Email: ${request['email']?.toString() ?? 'No Email'}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => _approveRequest(request), // استخدام دالة جديدة لقبول الطلب
        ),
      ),
    );
  }

  Future<void> _approveRequest(Map<String, dynamic> request) async {
    final studentId = request['id']; // تأكد من أن لديك معرف الطالب
    final studentData = {
      'id': studentId,
      'fullName': request['fullName'],
      'email': request['email'],
      'userToken': request['userToken'], // نقل userToken
      // أضف أي معلومات أخرى تحتاجها
    };

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('accepted_students')
        .doc(studentId)
        .set(studentData); // إضافة الطالب إلى المقبولين

    // حذف الطالب من طلبات التسجيل
    await FirebaseFirestore.instance
        .collection('registration_requests')
        .doc(studentId)
        .delete();
  }

  Widget _buildPreviousVideosList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('videos')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading videos'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No previous videos available', style: TextStyle(color: Colors.white)));
        }

        final videos = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(video['title'] ?? 'Untitled', style: const TextStyle(color: Colors.white)),
              subtitle: Text(video['description'] ?? 'No Description', style: const TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                onPressed: () {
                  // هنا يمكنك إضافة منطق لتشغيل الفيديو.
                },
              ),
            );
          },
        );
      },
    );
  }
}