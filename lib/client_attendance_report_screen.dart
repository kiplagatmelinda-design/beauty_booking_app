import 'package:flutter/material.dart';
import 'services_screen.dart';

class ClientAttendanceReportScreen extends StatefulWidget {
  @override
  _ClientAttendanceReportScreenState createState() =>
      _ClientAttendanceReportScreenState();
}

class _ClientAttendanceReportScreenState
    extends State<ClientAttendanceReportScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Client> _clients = [];
  Map<int, Map<String, int>> _summaries = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final clients = await _db.getClients();
    setState(() {
      _clients = clients;
    });
    for (var c in clients) {
      final summary = await _db.getAttendanceSummaryByClient(c.id!);
      _summaries[c.id!] = summary;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Client Attendance Report'),
          backgroundColor: Colors.pink),
      body: _clients.isEmpty
          ? Center(child: Text('No clients registered'))
          : ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                final sum = _summaries[client.id] ??
                    {'checked-in': 0, 'no-show': 0, 'late': 0};
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(client.name),
                    subtitle: Text(
                        'Phone: ${client.phone} | Preferred: ${client.preferredService}'),
                    trailing: Text(
                        '✅${sum['checked-in']} ❌${sum['no-show']} ⏰${sum['late']}'),
                  ),
                );
              },
            ),
    );
  }
}
