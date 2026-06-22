import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'booking_screen.dart';
import 'api_data_screen.dart';

// ========== NEW SCREENS (renamed) ==========
import 'register_client_screen.dart';
import 'mark_client_attendance_screen.dart';
import 'client_attendance_report_screen.dart';

// ========== SERVICE MODEL (unchanged) ==========
class Service {
  int? id;
  String name;
  String duration;
  double price;
  String icon;

  Service(
      {this.id,
      required this.name,
      required this.duration,
      required this.price,
      required this.icon});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
      'icon': icon,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      duration: map['duration'],
      price: map['price'],
      icon: map['icon'],
    );
  }
}

// ========== CLIENT MODEL (renamed from Student) ==========
class Client {
  int? id;
  String name;
  String phone; // instead of regNo
  String preferredService; // instead of class
  String createdAt;

  Client(
      {this.id,
      required this.name,
      required this.phone,
      required this.preferredService,
      required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'preferred_service': preferredService,
      'created_at': createdAt,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      preferredService: map['preferred_service'],
      createdAt: map['created_at'],
    );
  }
}

// ========== CLIENT ATTENDANCE MODEL (renamed) ==========
class ClientAttendance {
  int? id;
  int clientId;
  int? serviceId; // optional – could be the booked service
  String date;
  String status; // 'checked-in', 'no-show', 'late'
  String? timeIn;
  String? remarks;

  ClientAttendance(
      {this.id,
      required this.clientId,
      this.serviceId,
      required this.date,
      required this.status,
      this.timeIn,
      this.remarks});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'service_id': serviceId,
      'date': date,
      'status': status,
      'time_in': timeIn,
      'remarks': remarks,
    };
  }

  factory ClientAttendance.fromMap(Map<String, dynamic> map) {
    return ClientAttendance(
      id: map['id'],
      clientId: map['client_id'],
      serviceId: map['service_id'],
      date: map['date'],
      status: map['status'],
      timeIn: map['time_in'],
      remarks: map['remarks'],
    );
  }
}

// ========== DATABASE HELPER (extended) ==========
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = p.join(await getDatabasesPath(), 'beauty_booking.db');
    return await openDatabase(
      path,
      version: 3, // increment version
      onCreate: (db, version) async {
        // --- SERVICES TABLE ---
        await db.execute('''
          CREATE TABLE services(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            duration TEXT,
            price REAL,
            icon TEXT
          )
        ''');
        // Default services
        await db.insert('services', {
          'name': 'Hair Styling',
          'duration': '45 min',
          'price': 35,
          'icon': '✂️'
        });
        await db.insert('services', {
          'name': 'Facial Treatment',
          'duration': '60 min',
          'price': 50,
          'icon': '💆'
        });
        await db.insert('services', {
          'name': 'Manicure',
          'duration': '30 min',
          'price': 25,
          'icon': '💅'
        });
        await db.insert('services', {
          'name': 'Massage',
          'duration': '90 min',
          'price': 70,
          'icon': '💆‍♂️'
        });
        await db.insert('services', {
          'name': 'Makeup',
          'duration': '60 min',
          'price': 45,
          'icon': '💄'
        });
        await db.insert('services',
            {'name': 'Waxing', 'duration': '30 min', 'price': 30, 'icon': '✨'});

        // --- CLIENTS TABLE (renamed) ---
        await db.execute('''
          CREATE TABLE clients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT UNIQUE,
            preferred_service TEXT,
            created_at TEXT
          )
        ''');

        // --- CLIENT ATTENDANCE TABLE (renamed) ---
        await db.execute('''
          CREATE TABLE client_attendance(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER,
            service_id INTEGER,
            date TEXT,
            status TEXT,
            time_in TEXT,
            remarks TEXT,
            FOREIGN KEY(client_id) REFERENCES clients(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE clients(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              phone TEXT UNIQUE,
              preferred_service TEXT,
              created_at TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE client_attendance(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              client_id INTEGER,
              service_id INTEGER,
              date TEXT,
              status TEXT,
              time_in TEXT,
              remarks TEXT,
              FOREIGN KEY(client_id) REFERENCES clients(id)
            )
          ''');
        }
      },
    );
  }

  // --- SERVICE CRUD (unchanged) ---
  Future<int> insertService(Service service) async {
    Database db = await database;
    return await db.insert('services', service.toMap());
  }

  Future<int> updateService(Service service) async {
    Database db = await database;
    return await db.update('services', service.toMap(),
        where: 'id = ?', whereArgs: [service.id]);
  }

  Future<int> deleteService(int id) async {
    Database db = await database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Service>> getServices({String? searchQuery}) async {
    Database db = await database;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      List<Map<String, dynamic>> maps = await db.query(
        'services',
        where: 'name LIKE ?',
        whereArgs: ['%$searchQuery%'],
      );
      return maps.map((map) => Service.fromMap(map)).toList();
    } else {
      List<Map<String, dynamic>> maps = await db.query('services');
      return maps.map((map) => Service.fromMap(map)).toList();
    }
  }

  // --- CLIENT CRUD (renamed) ---
  Future<int> insertClient(Client client) async {
    Database db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients({String? searchQuery}) async {
    Database db = await database;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final List<Map<String, dynamic>> maps = await db.query(
        'clients',
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$searchQuery%', '%$searchQuery%'],
      );
      return maps.map((m) => Client.fromMap(m)).toList();
    } else {
      final List<Map<String, dynamic>> maps = await db.query('clients');
      return maps.map((m) => Client.fromMap(m)).toList();
    }
  }

  Future<int> updateClient(Client client) async {
    Database db = await database;
    return await db.update('clients', client.toMap(),
        where: 'id = ?', whereArgs: [client.id]);
  }

  Future<int> deleteClient(int id) async {
    Database db = await database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  // --- CLIENT ATTENDANCE CRUD (renamed) ---
  Future<int> insertClientAttendance(ClientAttendance attendance) async {
    Database db = await database;
    return await db.insert('client_attendance', attendance.toMap());
  }

  Future<List<ClientAttendance>> getAttendanceByDate(String date) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'client_attendance',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((m) => ClientAttendance.fromMap(m)).toList();
  }

  Future<List<ClientAttendance>> getAttendanceByClient(int clientId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'client_attendance',
      where: 'client_id = ?',
      whereArgs: [clientId],
    );
    return maps.map((m) => ClientAttendance.fromMap(m)).toList();
  }

  // --- REPORT QUERY (renamed) ---
  Future<Map<String, int>> getAttendanceSummaryByClient(int clientId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM client_attendance
      WHERE client_id = ?
      GROUP BY status
    ''', [clientId]);
    Map<String, int> summary = {'checked-in': 0, 'no-show': 0, 'late': 0};
    for (var row in maps) {
      summary[row['status']] = row['count'];
    }
    return summary;
  }
}

// ========== SERVICES SCREEN (with new menu items) ==========
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Service> _services = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await _db.getServices(searchQuery: _searchQuery);
    setState(() {
      _services = services;
    });
  }

  void _addOrEditService({Service? existing}) {
    // ... (same as before, keep as is)
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final durationController =
        TextEditingController(text: existing?.duration ?? '');
    final priceController =
        TextEditingController(text: existing?.price.toString() ?? '');
    final iconController = TextEditingController(text: existing?.icon ?? '✂️');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Service' : 'Add Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Service Name')),
              TextField(
                  controller: durationController,
                  decoration:
                      InputDecoration(labelText: 'Duration (e.g., 45 min)')),
              TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price (\$)'),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: iconController,
                  decoration: InputDecoration(labelText: 'Icon (emoji)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  durationController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  iconController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')));
                return;
              }
              final service = Service(
                id: existing?.id,
                name: nameController.text,
                duration: durationController.text,
                price: double.parse(priceController.text),
                icon: iconController.text,
              );
              if (isEditing) {
                await _db.updateService(service);
              } else {
                await _db.insertService(service);
              }
              _loadServices();
              Navigator.pop(ctx);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteService(Service service) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${service.name}?'),
        content: Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _db.deleteService(service.id!);
              _loadServices();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text('Service deleted')));
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          // API Icon (unchanged)
          IconButton(
            icon: Icon(Icons.api),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApiDataScreen()),
              );
            },
            tooltip: 'View API Data',
          ),
          // NEW: 3-dot menu for Client Attendance
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'register_client') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => RegisterClientScreen()));
              } else if (value == 'mark_attendance') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MarkClientAttendanceScreen()));
              } else if (value == 'report') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ClientAttendanceReportScreen()));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'register_client', child: Text('Register Client')),
              PopupMenuItem(
                  value: 'mark_attendance',
                  child: Text('Mark Client Check‑in')),
              PopupMenuItem(
                  value: 'report', child: Text('Client Attendance Report')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _loadServices();
              },
            ),
          ),
        ),
      ),
      body: _services.isEmpty
          ? Center(child: Text('No services. Tap + to add.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return Card(
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            serviceName: service.name,
                            servicePrice:
                                '\$${service.price.toStringAsFixed(0)}',
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _addOrEditService(existing: service),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(service.icon,
                            style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(service.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(service.duration,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('\$${service.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: Icon(Icons.edit,
                                    size: 20, color: Colors.blue),
                                onPressed: () =>
                                    _addOrEditService(existing: service)),
                            IconButton(
                                icon: Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                onPressed: () => _deleteService(service)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditService(),
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
