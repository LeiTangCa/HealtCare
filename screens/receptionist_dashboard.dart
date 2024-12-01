import 'package:flutter/material.dart';
import 'patient_list_for_recep.dart';
import 'add_patient.dart';
import 'doctor_messages.dart';

class ReceptionistDashboard extends StatelessWidget {
  final int userId; // Field for the logged-in patient's user ID

  const ReceptionistDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receptionist Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('View Patient List'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ListPatientsRecepScreen(userId: userId))),
          ),
          ListTile(
            title: const Text('Add New Patient'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPatientScreen())),
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
