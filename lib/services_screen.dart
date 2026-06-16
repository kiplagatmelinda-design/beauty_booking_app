import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'booking_screen.dart';
import 'api_data_screen.dart'; // <-- API screen import

// ========== SERVICE MODEL ==========
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

// ========== DATABASE HELPER ==========
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
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
  }

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
}

// ========== SERVICES SCREEN ==========
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
        // ========== API BUTTON ADDED HERE ==========
        actions: [
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
