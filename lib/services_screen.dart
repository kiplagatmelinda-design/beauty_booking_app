import 'package:flutter/material.dart';
import 'booking_screen.dart';

class ServicesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> services = const [
    {
      'name': 'Hair Styling',
      'duration': '45 min',
      'price': '\$35',
      'icon': '✂️',
    },
    {
      'name': 'Facial Treatment',
      'duration': '60 min',
      'price': '\$50',
      'icon': '💆',
    },
    {'name': 'Manicure', 'duration': '30 min', 'price': '\$25', 'icon': '💅'},
    {'name': 'Massage', 'duration': '90 min', 'price': '\$70', 'icon': '💆‍♂️'},
    {'name': 'Makeup', 'duration': '60 min', 'price': '\$45', 'icon': '💄'},
    {'name': 'Waxing', 'duration': '30 min', 'price': '\$30', 'icon': '✨'},
  ];

  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            elevation: 3,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(
                      serviceName: service['name']!,
                      servicePrice: service['price']!,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(service['icon']!, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    service['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['duration']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['price']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
