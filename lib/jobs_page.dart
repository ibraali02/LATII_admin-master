import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'JobDetailPage.dart';
import 'add_job_page.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String? selectedCategory;
  List<Map<String, dynamic>> jobs = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('new_jobs')
        .orderBy('publishedDate', descending: true)
        .get();

    final List<Map<String, dynamic>> fetchedJobs = result.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() {
      jobs = fetchedJobs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Listings',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF980E0E), Color(0xFF330000)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategories(),
              const SizedBox(height: 16),
              _buildJobCountText(),
              _jobsList(context),
              _buildAddJobButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _categoryButton('All'),
          const SizedBox(width: 8),
          _categoryButton('Full Time'),
          const SizedBox(width: 8),
          _categoryButton('Part Time'),
          const SizedBox(width: 8),
          _categoryButton('Remote'),
          const SizedBox(width: 8),
          _categoryButton('Productivity-Based'),
        ],
      ),
    );
  }

  Widget _categoryButton(String title) {
    bool isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = (isSelected && title == 'All') ? null : title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red[800]!),
          borderRadius: BorderRadius.circular(30),
          color: isSelected ? Colors.red[100] : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.red[800],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCountText() {
    final filteredJobs = selectedCategory == null || selectedCategory == 'All'
        ? jobs
        : jobs.where((job) => job['category'] == selectedCategory).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'Found ${filteredJobs.length} jobs',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _jobsList(BuildContext context) {
    final filteredJobs = selectedCategory == null || selectedCategory == 'All'
        ? jobs
        : jobs.where((job) => job['category'] == selectedCategory).toList();

    return Column(
      children: filteredJobs.map<Widget>((job) {
        return _jobCard(context, job);
      }).toList(),
    );
  }

  Widget _jobCard(BuildContext context, Map<String, dynamic> job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailPage(
              title: job['title'],
              description: job['description'],
              salary: job['salary'].toStringAsFixed(0),
              imageUrl: job['imageUrl'] ?? 'https://via.placeholder.com/100',
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.network(
                job['imageUrl'] ?? 'https://via.placeholder.com/100',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (job['location'] != null)
                      Text(job['location'] ?? '', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(job['description'] ?? ''),
                    const SizedBox(height: 8),
                    Text('LYD. ${job['salary'].toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(job['category'] ?? '', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    if (job['publishedDate'] != null)
                      Text(
                        'Published on: ${job['publishedDate'].toDate().toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildEditJobButton(context, job),
                  const SizedBox(height: 8),
                  _buildDeleteJobButton(context, job['id']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditJobButton(BuildContext context, Map<String, dynamic> job) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF980E0E),
            Color(0xFF330000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: IconButton(
        iconSize: 20,
        icon: const Icon(Icons.edit, color: Colors.white),
        onPressed: () => _showEditJobDialog(context, job),
      ),
    );
  }

  Widget _buildDeleteJobButton(BuildContext context, String jobId) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF980E0E),
            Color(0xFF330000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: IconButton(
        iconSize: 20,
        icon: const Icon(Icons.delete, color: Colors.white),
        onPressed: () => _confirmDeleteJob(jobId),
      ),
    );
  }

  void _showEditJobDialog(BuildContext context, Map<String, dynamic> job) {
    // منطق تعديل الوظيفة
  }

  void _confirmDeleteJob(String jobId) {
    // منطق تأكيد حذف الوظيفة
  }

  Widget _buildAddJobButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const AddJobPage(),
        ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF980E0E),
              Color(0xFF330000),
            ],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 10),
            Text('Add Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}