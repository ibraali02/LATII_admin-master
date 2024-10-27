import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'JobSeekerDetailPage.dart';

class JobSeekersPage extends StatefulWidget {
  const JobSeekersPage({super.key});

  @override
  _JobSeekersPageState createState() => _JobSeekersPageState();
}

class _JobSeekersPageState extends State<JobSeekersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> jobSeekers = [];
  bool _isLoading = true;
  List<String> selectedCourses = [];
  bool isGraduate = false;
  String selectedCity = 'All Cities';

  @override
  void initState() {
    super.initState();
    _fetchJobSeekers();
  }

  Future<void> _fetchJobSeekers() async {
    try {
      final snapshot = await _firestore.collection('job_seekers_accepted').get();
      setState(() {
        jobSeekers = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching job seekers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Seekers',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF980E0E),
                Color(0xFF330000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildCityFilters(),
          _buildFilters(),
          Expanded(child: _buildJobSeekersList()),
        ],
      ),
    );
  }

  Widget _buildCityFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.grey[200],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All Cities', 'Misrata', 'Tripoli', 'Benghazi'].map((city) {
            final isSelected = selectedCity == city;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCity = city;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF980E0E) : Colors.white,
                  border: Border.all(color: isSelected ? Colors.white : Color(0xFF980E0E)),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.only(right: 10),
                child: Text(
                  city,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF980E0E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildCourseFilters(),
          _buildGraduateCheckbox(),
        ],
      ),
    );
  }

  Widget _buildCourseFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['App Development', 'Cyber Security', 'Cloud Computing'].map((course) {
          final isSelected = selectedCourses.contains(course);
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected ? selectedCourses.remove(course) : selectedCourses.add(course);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF980E0E) : Colors.white,
                border: Border.all(color: isSelected ? Colors.white : Color(0xFF980E0E)),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.only(right: 10),
              child: Text(
                course,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF980E0E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGraduateCheckbox() {
    return CheckboxListTile(
      title: const Text("Graduate"),
      value: isGraduate,
      onChanged: (bool? value) {
        setState(() {
          isGraduate = value ?? false;
        });
      },
    );
  }

  Widget _buildJobSeekersList() {
    final filteredJobSeekers = jobSeekers.where((seeker) {
      final data = seeker.data();
      if (data == null) return false;

      bool cityMatches = selectedCity == 'All Cities' ||
          (data['city'] as String? ?? '').toLowerCase() == selectedCity.toLowerCase();
      bool matchesCourses = selectedCourses.isEmpty ||
          (data['courses'] as List<dynamic>?)!.any((course) => selectedCourses.contains(course)) ?? false;
      bool matchesGraduate = !isGraduate || (data['category'] as String? ?? '').toLowerCase() == 'graduate';

      return cityMatches && matchesCourses && matchesGraduate;
    }).toList();

    return ListView.builder(
      itemCount: filteredJobSeekers.length,
      itemBuilder: (context, index) {
        final seeker = filteredJobSeekers[index];
        final data = seeker.data() ?? {};

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        data['image'] as String? ?? 'images/default.png',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] as String? ?? "غير متوفر",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF980E0E),
                            ),
                          ),
                          Text(
                            data['university'] as String? ?? "غير متوفر",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF330000),
                            ),
                          ),
                          Text(
                            data['city'] as String? ?? "غير متو فر",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF330000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
               /* ElevatedButton(
                  onPressed: () {
                    // Implement edit functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF980E0E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Edit'),
                ),*/
                const SizedBox(height: 16),
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF980E0E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['about'] as String? ?? "No information available",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF330000),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Experience',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF980E0E),
                  ),
                ),
                const SizedBox(height: 8),
                _buildExperienceItem(data, 'experience'),
                const SizedBox(height: 16),
                Text(
                  'Education',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF980E0E),
                  ),
                ),
                const SizedBox(height: 8),
                _buildExperienceItem(data, 'education'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Implement export to PDF functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF980E0E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('View Profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data[type] as List<dynamic>? ?? [];
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                type == 'experience' ? Icons.work : Icons.school,
                color: Color(0xFF980E0E),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item as Map<String, dynamic>)['title'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF980E0E),
                    ),
                  ),
                  Text(
                    (item as Map<String, dynamic>)['subtitle'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF330000),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}