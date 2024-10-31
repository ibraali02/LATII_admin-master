import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'notifications_page.dart';
import 'settings_page.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _location;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> _news = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _fetchPosts() async {
    QuerySnapshot snapshot = await _firestore.collection('posts').get();
    setState(() {
      _news = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  void _addPost() async {
    if (_postController.text.isNotEmpty) {
      Map<String, dynamic> newPost = {
        'title': 'New Post',
        'date': DateTime.now().toString().split(' ')[0],
        'content': _postController.text,
        'likes': 0,
        'comments': 0,
      };

      if (_location != null) {
        newPost['location'] = _location!;
      }

      if (_image != null) {
        newPost['image'] = await _uploadImage(_image!);
      }

      DocumentReference docRef = await _firestore.collection('posts').add(newPost);
      newPost['id'] = docRef.id;
      setState(() {
        _news.insert(0, newPost);
      });
      _postController.clear();
      _image = null;
      _location = null;
    }
  }

  Future<String> _uploadImage(XFile image) async {
    Reference storageRef = _storage.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
    UploadTask uploadTask = storageRef.putFile(File(image.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _likePost(Map<String, dynamic> newsItem) {
    setState(() {
      newsItem['likes']++;
    });
    _updatePostInFirestore(newsItem);
  }

  void _commentPost(Map<String, dynamic> newsItem) {
    setState(() {
      newsItem['comments']++;
    });
    _updatePostInFirestore(newsItem);
  }

  Future<void> _updatePostInFirestore(Map<String, dynamic> newsItem) async {
    await _firestore.collection('posts').doc(newsItem['id']).update(newsItem);
  }

  Future<void> _deletePost(Map<String, dynamic> newsItem) async {
    await _firestore.collection('posts').doc(newsItem['id']).delete();
    setState(() {
      _news.remove(newsItem);
    });
  }

  void _confirmDeletePost(Map<String, dynamic> newsItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا البوست؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                _deletePost(newsItem);
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _showForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إنشاء بوست',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                    title: const Text('Doe'),
                    subtitle: Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.public, size: 16),
                          label: const Text('عام'),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('ألبوم'),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: const InputDecoration(
                        hintText: "ماذا يدور في ذهنك؟",
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.file(
                        File(_image!.path),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(Icons.image, 'صورة', Colors.green, () async {
                        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                        setState(() {
                          _image = pickedFile;
                        });
                      }),
                      _buildActionButton(Icons.person, 'تاج أشخاص', Colors.blue, () {}),
                      _buildActionButton(Icons.emoji_emotions, 'شعور', Colors.yellow, () {}),
                      _buildActionButton(Icons.location_on, 'تحديد الموقع', Colors.red, () async {
                        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                        setState(() {
                          _location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF980E0E),
                            Color(0xFF330000),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                      child: ElevatedButton(
                        child: const Text('نشر'),
                        onPressed: () {
                          _addPost();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _customAppBar(context),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                _postInput(),
                const SizedBox(height: 20),
                _newsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _customAppBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مرحبًا، LATI',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsPage()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _postInput() {
    return GestureDetector(
      onTap: _showForm,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: Colors.red),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'أضف بوست...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newsSection() {
    return Column(
      children: _news.map((newsItem) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
                title: const Text(
                  'LATI',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    Text(newsItem['date']),
                    const SizedBox(width: 5),
                    const Icon(Icons.public, size: 12),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDeletePost(newsItem);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('حذف'),
                      ),
                    ];
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(newsItem['content']),
              ),
              if (newsItem.containsKey('image'))
                Image.network(
                  newsItem['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              if (newsItem.containsKey('location'))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        newsItem['location'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPostAction(Icons.thumb_up_outlined, 'Like (${newsItem['likes'] ?? '0'})', () {
                    _likePost(newsItem);
                  }),
                  _buildPostAction(Icons.comment_outlined, 'Comment (${newsItem['comments'] ?? '0'})', () {
                    _commentPost(newsItem);
                  }),
                ],
              ),
              const Divider(height: 2),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPostAction(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}