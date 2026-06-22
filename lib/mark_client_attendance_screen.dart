import 'package:flutter/material.dart';
import 'services_screen.dart';

class MarkClientAttendanceScreen extends StatefulWidget {
  @override
  _MarkClientAttendanceScreenState createState() =>
      _MarkClientAttendanceScreenState();
}

class _MarkClientAttendanceScreenState
    extends State<MarkClientAttendanceScreen> {
  List<Client> _clients = [];
  Map<int, String> _statuses = {};
  final DatabaseHelper _db = DatabaseHelper();
  String _selectedDate = DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await _db.getClients();
    setState(() {
      _clients = clients;
      for (var c in clients) {
        _statuses[c.id!] = 'checked-in'; // default
      }
    });
  }

  Future<void> _saveAttendance() async {
    for (var client in _clients) {
      final att = ClientAttendance(
        clientId: client.id!,
        date: _selectedDate,
        status: _statuses[client.id] ?? 'checked-in',
        serviceId: null, // optional
      );
      await _db.insertClientAttendance(att);
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance saved for $_selectedDate')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Mark Client Check‑in'), backgroundColor: Colors.pink),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Date: $_selectedDate'),
                IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030));
                      if (date != null) {
                        setState(() {
                          _selectedDate =
                              date.toIso8601String().substring(0, 10);
                        });
                      }
                    }),
                Spacer(),
                ElevatedButton(
                    onPressed: _saveAttendance,
                    child: Text('Save'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.pink)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return Card(
                  child: ListTile(
                    title: Text(client.name),
                    subtitle: Text('Phone: ${client.phone}'),
                    trailing: DropdownButton<String>(
                      value: _statuses[client.id] ?? 'checked-in',
                      items: ['checked-in', 'no-show', 'late']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _statuses[client.id!] = val!;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
