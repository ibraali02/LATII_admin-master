import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Edit_course.dart';
import 'course_details_page.dart';
import 'add_course_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String? selectedCategory;
  final List<Map<String, dynamic>> courses = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  void _fetchCourses() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await _firestore.collection('courses').get();
      setState(() {
        courses.clear();
        for (var doc in snapshot.docs) {
          courses.add({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        }
      });
    } catch (e) {
      print("Error fetching courses: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(
          courseId: course['id'],
          courseName: course['title'],
          imageUrl: course['image'],

        ),
      ),
    );
  }

  void _editCourse(Map<String, dynamic> course) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditCoursePage(course: course)),
    );
    if (result == true) {
      _fetchCourses();
    }
  }

  void _showDeleteConfirmationDialog(String courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this course?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteCourse(courseId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
      _fetchCourses();
    } catch (e) {
      print("Error deleting course: $e");
    }
  }

  void _startCourse(Map<String, dynamic> course) async {
    try {
      // Add the course to the starting_courses collection with the course ID
      await _firestore.collection('starting_courses').add({
        'courseId': course['id'], // Save the course token
        'title': course['title'],
        'description': course['description'],
        'image': course['image'],
        'duration': course['duration'],
        'location': course['location'],
        'startedAt': FieldValue.serverTimestamp(), // Save the timestamp when the course was started

        // Add any other fields you need
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course started successfully!')),
      );
    } catch (e) {
      print("Error starting course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start course')),
      );
    }
  }

  Widget _actionButtonWithIcon(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF980E0E), Color(0xFF330000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: const EdgeInsets.all(6),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for courses...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF980E0E)),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _categoryCard('Programming', 'images/cod.png', '150+ Courses'),
              _categoryCard('Design', 'images/dis.png', '80+ Courses'),
              _categoryCard('Cybersecurity', 'images/sy.png', '60+ Courses'),
              _categoryCard('App Development', 'images/app.png', '90+ Courses'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(String title, String imagePath, String courseCount) {
    bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = isSelected ? null : title;
        });
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF980E0E), Color(0xFF330000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
              color: isSelected ? Colors.white : const Color(0xFF980E0E),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              courseCount,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToCourseDetails(course),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                course['image'] ?? 'https://via.placeholder.com/400x200',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          course['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          _actionButtonWithIcon(
                            Icons.edit,
                                () => _editCourse(course),
                          ),
                          const SizedBox(width: 8),
                          _actionButtonWithIcon(
                            Icons.delete,
                                () => _showDeleteConfirmationDialog(course['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course['description'] ?? 'No Description',
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        course['duration'] ?? 'Not Specified',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        course['location'] ?? 'Not Specified',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _startCourse(course),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF980E0E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Start Course'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Courses', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF980E0E), Color(0xFF330000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSearchBar(),
          _buildCategorySection(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: courses.length,
              itemBuilder: (context, index) => _buildCourseCard(courses[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCoursePage()),
          );
          if (result == true) {
            _fetchCourses();
          }
        },
        label: const Text(
          'Add Course',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF980E0E),
      ),
    );
  }
}