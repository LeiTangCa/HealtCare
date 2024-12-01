import 'package:flutter/material.dart';
import 'patient_messages.dart'; // Ensure this is the correct import path
import 'patient_diagnosis.dart';

class PatientDashboard extends StatelessWidget {
  final int userId; // Field for the logged-in patient's user ID

  const PatientDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('View Messages'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientMessagesScreen(userId: userId), // Pass the userId to the messages screen
              ),
            ),
          ),
          ListTile(
            title: const Text('View Diagnosis'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDiagnosisScreen(userId: userId), // Pass the userId to the diagnosis screen
              ),
            ),
          ),
          // Add other dashboard options here as needed
        ],
      ),
    );
  }
}
