import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiDataScreen extends StatefulWidget {
  @override
  _ApiDataScreenState createState() => _ApiDataScreenState();
}

class _ApiDataScreenState extends State<ApiDataScreen> {
  List<dynamic> _records = [];
  bool _isLoading = true;
  String _error = '';

  final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _records = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Posts'),
        backgroundColor: Colors.pink,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _fetchData, child: Text('Retry')),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final post = _records[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('${post['id']}. ${post['title']}'),
                        subtitle: Text(post['body']),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
