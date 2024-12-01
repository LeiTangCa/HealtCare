import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientDiagnosisScreen extends StatefulWidget {
  final int userId; // The patient's user ID

  const PatientDiagnosisScreen({super.key, required this.userId});

  @override
  _PatientDiagnosisScreenState createState() => _PatientDiagnosisScreenState();
}

class _PatientDiagnosisScreenState extends State<PatientDiagnosisScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchDiagnosis();
  }

  // Fetch the messages for the patient from the server
  Future<void> _fetchDiagnosis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost/mhcare/backend/fetch_diagnosis.php?userId=${widget.userId}'), // Replace with your PHP script URL
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

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diagnosis'),
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
                  ? const Center(child: Text('No diagnosis found.'))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isSentByUser = message['patient_id'] == widget.userId;
                        

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              isSentByUser
                                  ? 'Sent to: ${message['patient_name']}'
                                  : 'Received from: ${message['doctor_name']}',
                              style: TextStyle(
                                fontWeight: isSentByUser ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(message['diagnosis']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  message['created_at'] ?? '', // Assuming the API returns a timestamp
                                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),
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
