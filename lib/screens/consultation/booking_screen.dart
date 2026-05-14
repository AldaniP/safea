import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/consultation_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<Map<String, dynamic>> _mockTherapists = [
    {
      'id': 't1',
      'name': 'Dr. Sarah Jenkins',
      'specialization': 'Kecemasan & Stres',
      'rating': 4.9,
    },
    {
      'id': 't2',
      'name': 'Dr. Marcus Webb',
      'specialization': 'Depresi & CBT',
      'rating': 4.8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesan Konsultasi Profesional')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _mockTherapists.length,
        itemBuilder: (context, index) {
          final therapist = _mockTherapists[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        therapist['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          Text('${therapist['rating']}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    therapist['specialization'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mock booking for tomorrow
                        final scheduledTime = DateTime.now().add(
                          const Duration(days: 1),
                        );

                        unawaited(
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );

                        await ConsultationService.instance.bookSession(
                          'current_user_id',
                          therapist['id'],
                          scheduledTime,
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // Close loading

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sesi berhasil dipesan dengan ${therapist['name']}!',
                              ),
                            ),
                          );

                          // Navigate back or to a sessions list
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Pesan Sesi'),
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
