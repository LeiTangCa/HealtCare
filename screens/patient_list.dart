import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'update_patient.dart'; // Import UpdatePatientScreen

class ListPatientsScreen extends StatefulWidget {
  final int userId; // Field for the logged-in user's ID (doctor ID)

  const ListPatientsScreen({super.key, required this.userId});

  @override
  _ListPatientsScreenState createState() => _ListPatientsScreenState();
}

class _ListPatientsScreenState extends State<ListPatientsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _patients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  // Fetch the list of patients from the server
  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost/mhcare/backend/fetch_patients.php')); // Replace with your PHP script URL

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _patients = data;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load patients. Please try again.";
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

  // Send a message to the selected patient
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
                Uri.parse('http://localhost/mhcare/backend/send_message.php'), // Replace localhost with your machine's IP address
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

  // Send a diagnosis to the selected patient
  Future<void> _sendDiagnosis(int doctorId, int patientId) async {
    TextEditingController diagnosisController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Diagnosis'),
        content: TextField(
          controller: diagnosisController,
          decoration: const InputDecoration(
            labelText: 'Enter the diagnosis',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog

              // Log parameters for debugging
              print('Sending diagnosis: doctorId=$doctorId, patientId=$patientId, diagnosis=${diagnosisController.text}');

              try {
                final response = await http.post(
                  Uri.parse('http://localhost/mhcare/backend/send_diagnosis.php'), // Replace localhost with your machine's IP
                  headers: {"Content-Type": "application/x-www-form-urlencoded"},
                  body: {
                    'doctorId': doctorId.toString(),
                    'patientId': patientId.toString(),
                    'diagnosis': diagnosisController.text,
                  },
                );

                print('Response status: ${response.statusCode}');
                print('Raw response body: ${response.body}');

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  if (data['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Diagnosis sent successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send diagnosis: ${data['message']}')),
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
        title: const Text('Patients List'),
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
              : ListView.builder(
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(patient['name'] ?? 'N/A'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Address: ${patient['address'] ?? 'N/A'}"),
                            Text("DOB: ${patient['dob'] ?? 'N/A'}"),
                            Text("Patient Number: ${patient['patient_number'] ?? 'N/A'}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdatePatientScreen(patient: patient),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.message),
                              onPressed: () {
                                int senderId = widget.userId; // Use logged-in user ID as senderId
                                int receiverId = int.parse(patient['id']); // Convert String to int
                                _sendMessage(senderId, receiverId);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                int doctorId = widget.userId; // Use logged-in user ID as doctorId
                                int patientId = int.parse(patient['id']); // Convert String to int
                                _sendDiagnosis(doctorId, patientId);
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
