import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientMessagesScreen extends StatefulWidget {
  final int userId; // The patient's user ID

  const PatientMessagesScreen({super.key, required this.userId});

  @override
  _PatientMessagesScreenState createState() => _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends State<PatientMessagesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  // Fetch the messages for the patient from the server
  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost/mhcare/backend/fetch_messages.php?userId=${widget.userId}'), // Replace with your PHP script URL
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages = data;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load messages. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred. Please check your connection.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Send a message to the selected recipient 
  Future<void> _sendMessage(int senderId, int receiverId) async {
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Enter your message',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog

              try {
                final response = await http.post(
                  Uri.parse('http://localhost/mhcare/backend/send_message.php'), 
                  headers: {"Content-Type": "application/x-www-form-urlencoded"},
                  body: {
                    'senderId': senderId.toString(),
                    'receiverId': receiverId.toString(),
                    'message': messageController.text,
                  },
                );

                print('Response status: ${response.statusCode}');
                print('Raw response body: ${response.body}'); // Log the raw response

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body); // Decoding JSON
                  if (data['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message sent successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send message: ${data['message']}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error connecting to the server')),
                  );
                }
              } catch (e) {
                print('Error: $e'); // Log the error for debugging
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('An error occurred: $e')),
                );
              }
            },
            child: const Text('Send'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without sending
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Messages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _messages.isEmpty
                  ? const Center(child: Text('No messages found.'))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isSentByUser = message['sender_id'] == widget.userId;
                        

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              isSentByUser
                                  ? 'Sent to: ${message['receiver_name']}'
                                  : 'Received from: ${message['sender_name']}',
                              style: TextStyle(
                                fontWeight: isSentByUser ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(message['message']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  message['created_at'] ?? '', // Assuming the API returns a timestamp
                                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message),
                                  onPressed: () {
                                    // For patient, the sender is the patient (widget.userId)
                                    // and the receiver is the doctor.
                                    int senderId = widget.userId; // Patient is sending the message
                                    int receiverId = message['sender_id']; // Doctor is the receiver
                                    _sendMessage(senderId, receiverId);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
