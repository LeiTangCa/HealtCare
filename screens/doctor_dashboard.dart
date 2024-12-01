import 'package:flutter/material.dart';
import 'patient_list.dart';
import 'doctor_diagnosis.dart';
import 'doctor_messages.dart';


class DoctorDashboard extends StatelessWidget {
  final int userId; // Field for the logged-in patient's user ID

  const DoctorDashboard({super.key, required this.userId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('View Patient List'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ListPatientsScreen(userId: userId))),
          ),

          ListTile(
            title: const Text('View Diagnosis List'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorDiagnosisScreen(userId: userId))),
          ),

          ListTile(
            title: const Text('View Message List'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorMessagesScreen(userId: userId))),
          ),
        ],
      ),
    );
  }
}
