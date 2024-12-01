import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'doctor_dashboard.dart';
import 'receptionist_dashboard.dart';
import 'patient_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both username and password.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost/mhcare/backend/login.php'), // Replace with your PHP server URL
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final int userId = data['id']; // Get the userId from the response
          final String role = data['role'];
          if (data['role'] == 'doctor') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorDashboard(userId: userId)));
            } 
          else if (data['role'] == 'receptionist') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ReceptionistDashboard(userId: userId)));
            } 
          else if (data['role'] == 'patient') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDashboard(userId: userId)));
            }
          else {
            setState(() {_errorMessage = data['message'];});
            }
          } 
      }
      else {
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
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
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
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
