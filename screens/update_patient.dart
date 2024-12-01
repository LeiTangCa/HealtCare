import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdatePatientScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const UpdatePatientScreen({super.key, required this.patient});

  @override
  _UpdatePatientScreenState createState() => _UpdatePatientScreenState();
}

class _UpdatePatientScreenState extends State<UpdatePatientScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing patient data
    _nameController = TextEditingController(text: widget.patient['name']);
    _addressController = TextEditingController(text: widget.patient['address']);
    _dobController = TextEditingController(text: widget.patient['dob']);
  }

  Future<void> _updatePatient() async {
    if (!_formKey.currentState!.validate()) return;

    print("Sending the following data to the backend:");
    print("id: ${widget.patient['patientid']}");
    print("name: ${_nameController.text}");
    print("address: ${_addressController.text}");
    print("dob: ${_dobController.text}");

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost/mhcare/backend/update_patient.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'id': widget.patient['patientid'].toString(),
          'name': _nameController.text,
          'address': _addressController.text,
          'dob': _dobController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient updated successfully!')),
          );
          Navigator.pop(context, true); // Return to previous screen with success flag
        } else {
          setState(() {
            _errorMessage = data['message'];
          });
        }
      } else {
        setState(() {
          _errorMessage = "Server error. Please try again later.";
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
        title: const Text('Update Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) => value!.isEmpty ? 'Address is required' : null,
                ),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  validator: (value) => value!.isEmpty ? 'Date of Birth is required' : null,
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _updatePatient,
                        child: const Text('Update Patient'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
