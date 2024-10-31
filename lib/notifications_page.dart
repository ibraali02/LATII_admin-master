import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF980E0E),
                Color(0xFF330000),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('job_seekers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          _notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notification = _notifications[index];
              return _notificationItem(
                context,
                notification.data()!,
                notification.id,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadAllNotifications,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> _uploadAllNotifications() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('job_seekers').get();
      for (var document in snapshot.docs) {
        await _firestore.collection('notifications').add({
          'name': document.data()['name'],
          'age': document.data()['age'],
          'city': document.data()['city'],
          'courses': document.data()['courses'],
          'cv_image': document.data()['cv_image'], // إضافة الحقل
          'email': document.data()['email'],
          'gender': document.data()['gender'], // إضافة الحقل
          'graduate': document.data()['graduate'],
          'image': document.data()['image'],
          'phone': document.data()['phone'],
          'university': document.data()['university'],
          'timestamp': document.data()['timestamp'],
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications uploaded successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading notifications: $e')),
      );
      print('Error uploading notifications: $e'); // Debugging line
    }
  }

  Widget _notificationItem(BuildContext context, Map<String, dynamic> data, String notificationId) {
    final String studentName = data['name'] ?? 'Unknown';
    final String courseId = (data['courses'] as List?)?.join(', ') ?? 'No courses';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.notifications, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$studentName طلب التسجيل في $courseId',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['timestamp']?.toDate().toString() ?? 'No time',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    _acceptNotification(notificationId);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _rejectNotification(notificationId);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptNotification(String notificationId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestDoc =
      await _firestore.collection('job_seekers').doc(notificationId).get();

      if (requestDoc.exists) {
        // حفظ جميع البيانات في job_seekers_accepted
        await _firestore.collection('job_seekers_accepted').add({
          'name': requestDoc.data()?['name'],
          'age': requestDoc.data()?['age'],
          'city': requestDoc.data()?['city'],
          'courses': requestDoc.data()?['courses'],
          'cv_image': requestDoc.data()?['cv_image'],
          'email': requestDoc.data()?['email'],
          'gender': requestDoc.data()?['gender'],
          'graduate': requestDoc.data()?['graduate'],
          'image': requestDoc.data()?['image'],
          'phone': requestDoc.data()?['phone'],
          'university': requestDoc.data()?['university'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        // حذف الإشعار بعد قبوله
        await _firestore.collection('job_seekers').doc(notificationId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification accepted successfully.')),
        );
      } else {
        print('Request document does not exist: $notificationId'); // Debugging line
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting notification: $e')),
      );
      print('Error accepting notification: $e'); // Debugging line
    }
  }

  Future<void> _rejectNotification(String notificationId) async {
    try {
      await _firestore.collection('job_seekers').doc(notificationId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification rejected successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting notification: $e')),
      );
      print('Error rejecting notification: $e'); // Debugging line
    }
  }
}