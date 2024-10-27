import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatePage extends StatefulWidget {
  final String courseId; // استقبل courseId من الصفحة السابقة

  const RatePage({super.key, required this.courseId});

  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  final List<Map<String, dynamic>> _ratings = [];
  final TextEditingController _weekTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingRatings(); // تحميل التقييمات الموجودة عند بدء الصفحة
  }

  Future<void> _loadExistingRatings() async {
    // تحميل التقييمات الموجودة من Firestore
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('starting_courses')
          .doc(widget.courseId)
          .collection('ratings')
          .get();

      setState(() {
        _ratings.addAll(snapshot.docs.map((doc) {
          return {
            'title': doc['title'],
            'rating': doc['rating'],
          };
        }).toList());
      });
    } catch (e) {
      print("Error loading ratings: $e");
    }
  }

  void _showAddWeekDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Week'),
          content: TextField(
            controller: _weekTitleController,
            decoration: const InputDecoration(hintText: 'Enter week title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addWeek();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addWeek() async {
    String title = _weekTitleController.text.trim();
    if (title.isNotEmpty) {
      try {
        // إضافة الأسبوع الجديد إلى Firestore
        await FirebaseFirestore.instance
            .collection('starting_courses')
            .doc(widget.courseId)
            .collection('ratings')
            .add({'title': title, 'rating': 0}); // افتراضياً، التقييم 0

        setState(() {
          _ratings.add({'title': title, 'rating': 0}); // تحديث الواجهة
        });
        _weekTitleController.clear(); // مسح حقل الإدخال
      } catch (e) {
        print("Error adding week: $e");
      }
    }
  }

  void _showRatingDialog(String title, int index) {
    double rating = _ratings[index]['rating'].toDouble();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF980E0E),
                  const Color(0xFFFF5A5A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rate $title',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: rating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: rating.round().toString(),
                      activeColor: Colors.yellow,
                      inactiveColor: Colors.grey,
                      onChanged: (double value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    ),
                    Text(
                      'Rating: ${rating.round()}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _ratings[index]['rating'] = rating.round();
                              // حفظ التقييم في Firestore
                              FirebaseFirestore.instance
                                  .collection('starting_courses')
                                  .doc(widget.courseId)
                                  .collection('ratings')
                                  .where('title', isEqualTo: title)
                                  .get()
                                  .then((snapshot) {
                                if (snapshot.docs.isNotEmpty) {
                                  snapshot.docs.first.reference.update({'rating': rating.round()});
                                }
                              });
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF980E0E),
              Color(0xFFFF5A5A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Rate',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddWeekDialog, // فتح دايلوج لإضافة أسبوع جديد
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: _ratings.asMap().entries.map((entry) {
          int index = entry.key;
          var rating = entry.value;

          return _buildRatingCard(rating['title'], rating['rating'], index);
        }).toList(),
      ),
    );
  }

  Widget _buildRatingCard(String title, int rating, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                );
              }),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showRatingDialog(title, index);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: const Color(0xFF980E0E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  elevation: 5,
                ),
                child: const Text('Rate Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}