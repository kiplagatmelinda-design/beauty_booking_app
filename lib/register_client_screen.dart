import 'package:flutter/material.dart';
import 'services_screen.dart'; // reuse DatabaseHelper

class RegisterClientScreen extends StatefulWidget {
  @override
  _RegisterClientScreenState createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final preferredServiceController = TextEditingController();
  final DatabaseHelper _db = DatabaseHelper();

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        name: nameController.text,
        phone: phoneController.text,
        preferredService: preferredServiceController.text,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _db.insertClient(client);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Client registered')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Register Client'), backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: preferredServiceController,
                  decoration: InputDecoration(
                      labelText: 'Preferred Service (e.g., Hair Styling)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _saveClient,
                  child: Text('Register'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.pink)),
            ],
          ),
        ),
      ),
    );
  }
}
