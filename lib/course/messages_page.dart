import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesPage extends StatefulWidget {
  final String courseToken;

  const MessagesPage({
    super.key,
    required this.courseToken,
  });

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  late CollectionReference _messagesRef;
  late String _userId;
  String? _documentId;

  @override
  void initState() {
    super.initState();
    _messagesRef = FirebaseFirestore.instance.collection('starting_courses');
    _userId = 'user123'; // Replace with the actual user ID
    _fetchDocumentId();
  }

  Future<void> _fetchDocumentId() async {
    try {
      QuerySnapshot snapshot = await _messagesRef
          .where('courseId', isEqualTo: widget.courseToken)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _documentId = snapshot.docs.first.id; // Get the first matching document ID
        });
      }
    } catch (e) {
      print("Error fetching document ID: $e");
    }
  }

  Future<void> _sendMessage(String messageContent) async {
    if (_documentId != null && messageContent.isNotEmpty) {
      try {
        await _messagesRef
            .doc(_documentId) // Use the fetched document ID
            .collection('messages')
            .add({
          'sender': _userId,
          'time': FieldValue.serverTimestamp(),
          'content': messageContent,
          'courseId': widget.courseToken,
        });

        _messageController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(thickness: 2, color: Colors.grey),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _documentId != null
                  ? _messagesRef
                  .doc(_documentId) // Use the fetched document ID
                  .collection('messages')
                  .orderBy('time')
                  .snapshots()
                  : Stream.empty(), // Empty stream until document ID is fetched
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Message(
                    sender: data['sender'] == _userId ? 'You' : data['sender'],
                    time: (data['time'] as Timestamp?)?.toDate().toLocal().toString().substring(10, 15) ?? '',
                    content: data['content'] ?? '',
                  );
                }).toList();

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.sender == 'You';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.orange : Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              message.time,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendMessage(_messageController.text);
            },
          ),
        ],
      ),
    );
  }
}

class Message {
  final String sender;
  final String time;
  final String content;

  Message({
    required this.sender,
    required this.time,
    required this.content,
  });
}