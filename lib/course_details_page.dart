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
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(courseName),
                  background: imageUrl != null
                      ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
                backgroundColor: const Color(0xFF980E0E),
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

  Widget _buildRegistrationRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('registration_requests')
          .where('courseId', isEqualTo: courseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading registration requests'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No new registration requests', style: TextStyle(color: Colors.white)));
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            return _buildRequestCard(request, requests[index].id);
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
      child: ExpansionTile(
        title: Text(
          'Name: ${student['fullName']?.toString() ?? 'No Name'}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Email: ${student['email']?.toString() ?? 'No Email'}',
          style: const TextStyle(color: Colors.white70),
        ),
        iconColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', student['phone']?.toString() ?? 'No Phone'),
                _buildInfoRow('Education', student['education']?.toString() ?? 'N/A'),
                _buildInfoRow('Has Job', (student['hasJob'] as bool?) == true ? 'Yes' : 'No'),
                _buildInfoRow('Has Computer', (student['hasComputer'] as bool?) == true ? 'Yes' : 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, String requestId) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.white.withOpacity(0.1),
      child: ExpansionTile(
        title: Text(
          'Name: ${request['fullName']?.toString() ?? 'No Name'}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Email: ${request['email']?.toString() ?? 'No Email'}',
          style: const TextStyle(color: Colors.white70),
        ),
        iconColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', request['phone']?.toString() ?? 'No Phone'),
                _buildInfoRow('Education', request['education']?.toString() ?? 'N/A'),
                _buildInfoRow('Has Job', (request['hasJob'] as bool?) == true ? 'Yes' : 'No'),
                _buildInfoRow('Has Computer', (request['hasComputer'] as bool?) == true ? 'Yes' : 'No'),
                _buildInfoRow('Age', request['age']?.toString() ?? 'N/A'),
                _buildInfoRow('Qualification', request['qualification']?.toString() ?? 'N/A'),
                _buildInfoRow('Graduation Date', request['graduationDate']?.toString() ?? 'N/A'),
                _buildInfoRow('Nearest City', request['nearestCity']?.toString() ?? 'N/A'),
                _buildInfoRow('Residence', request['residence']?.toString() ?? 'N/A'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _confirmRegistration(request, requestId),
                      child: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _rejectRegistration(requestId),
                      child: const Text('Reject'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRegistration(Map<String, dynamic> registration, String registrationId) async {
    // نقل البيانات إلى مجموعة accepted_students داخل الدورة
    await FirebaseFirestore.instance.collection('courses').doc(courseId).collection('accepted_students').doc(registrationId).set({
      'courseId': registration['courseId'],
      'fullName': registration['fullName'],
      'email': registration['email'],
      'phone': registration['phone'],
      'education': registration['education'],
      'hasJob': registration['hasJob'],
      'hasComputer': registration['hasComputer'],
      'nearestCity': registration['nearestCity'],
      'residence': registration['residence'],
      'qualification': registration['qualification'],
      'graduationDate': registration['graduationDate'],
      'isGraduated': registration['isGraduated'],
      'age': registration['age'],
      'institution': registration['institution'],
      'userToken': registration['userToken'],
    });

    // حذف الطلب من قائمة الطلبات
    await FirebaseFirestore.instance.collection('registration_requests').doc(registrationId).delete();
  }

  Future<void> _rejectRegistration(String registrationId) async {
    await FirebaseFirestore.instance.collection('registration_requests').doc(registrationId).delete();
  }
}