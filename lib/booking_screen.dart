import 'package:flutter/material.dart';

class BookingScreen extends StatelessWidget {
  final String serviceName;
  final String servicePrice;

  const BookingScreen({
    super.key,
    required this.serviceName,
    required this.servicePrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book $serviceName'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 80, color: Colors.pink),
            const SizedBox(height: 20),
            Text(
              'Booking: $serviceName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: $servicePrice',
              style: const TextStyle(fontSize: 18, color: Colors.pink),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
