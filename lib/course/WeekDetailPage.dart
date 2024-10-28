import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeekDetailPage extends StatelessWidget {
  final String courseId;
  final String weekTitle;

  const WeekDetailPage({super.key, required this.courseId, required this.weekTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(weekTitle),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('starting_courses')
            .doc(courseId)
            .collection('weeks')
            .doc(weekTitle) // استخدام عنوان الأسبوع كمستند (يمكن تغييره حسب الحاجة)
            .collection('ratings')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading ratings'));
          }

          final ratings = snapshot.data!.docs.map((doc) => doc['title']).toList();

          return ListView.builder(
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(ratings[index]),
              );
            },
          );
        },
      ),
    );
  }
}