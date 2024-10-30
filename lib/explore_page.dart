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
  bool showOnlyStarted = false;
  bool showOnlyFinished = false;
  bool showOnlyUpcoming = false;
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
      List<Map<String, dynamic>> allCourses = snapshot.docs.map((doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        };
      }).toList();

      setState(() {
        courses.clear();
        for (var course in allCourses) {
          if ((showOnlyStarted && course['isStarted']) ||
              (showOnlyFinished && course['isFinished']) ||
              (showOnlyUpcoming && !course['isStarted']) ||
              (!showOnlyStarted && !showOnlyFinished && !showOnlyUpcoming)) {
            courses.add(course);
          }
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
          imageUrl: course['imageUrl'],
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
      if (course['isStarted'] == true) {
        await _firestore.collection('courses').doc(course['id']).update({
          'isStarted': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course has been stopped.')),
        );
      } else {
        await _firestore.collection('courses').doc(course['id']).update({
          'isStarted': true,
          'startTime': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course started successfully!')),
        );
      }
      _fetchCourses();
    } catch (e) {
      print("Error starting/stopping course: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update course status')),
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
          hintText: 'Search courses...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                String searchText = _searchController.text.toLowerCase();
                courses.retainWhere((course) =>
                course['title'].toLowerCase().contains(searchText) ||
                    course['description'].toLowerCase().contains(searchText));
              });
            },
          ),
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

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                showOnlyFinished = true;
                showOnlyStarted = false;
                showOnlyUpcoming = false;
              });
              _fetchCourses();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: showOnlyFinished ? const Color(0xFF980E0E) : Colors.white,
              foregroundColor: showOnlyFinished ? Colors.white : Colors.black,
            ),
            child: const Text('Finished Courses'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showOnlyUpcoming = true;
                showOnlyStarted = false;
                showOnlyFinished = false;
              });
              _fetchCourses();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: showOnlyUpcoming ? const Color(0xFF980E0E) : Colors.white,
              foregroundColor: showOnlyUpcoming ? Colors.white : Colors.black,
            ),
            child: const Text('Upcoming Courses'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    Widget statusIcon;
    Color statusColor;
    String statusText;

    if (course['isFinished'] == true) {
      statusIcon = const Icon(Icons.check_circle, color: Color(0xFF980E0E));
      statusColor = const Color(0xFF980E0E);
      statusText = 'Finished';
    } else if (course['isStarted'] == true) {
      statusIcon = const Icon(Icons.play_circle, color: Color(0xFF980E0E));
      statusColor = const Color(0xFF980E0E);
      statusText = 'Started';
    } else {
      statusIcon = const Icon(Icons.access_time, color: Color(0xFF980E0E));
      statusColor = const Color(0xFF980E0E);
      statusText = 'Upcoming';
    }

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
                course['imageUrl'] ?? 'https://via.placeholder.com/400x200',
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
                          statusIcon,
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
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
                  // عرض السعر
                  Text(
                    (course['price'] == 0 || course['price'] == null)
                        ? 'Free'
                        : '\$${course['price']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!(course['isStarted'] == true || course['isFinished'] == true))
                        _actionButtonWithIcon(Icons.play_arrow, () => _startCourse(course)),
                      _actionButtonWithIcon(Icons.edit, () => _editCourse(course)),
                      _actionButtonWithIcon(Icons.delete, () => _showDeleteConfirmationDialog(course['id'])),

                    ],
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
        title: const Text('Explore Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCoursePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategorySection(),
          _buildFilterSection(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return _buildCourseCard(courses[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}