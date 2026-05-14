import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  final List<Map<String, dynamic>> _mockPosts = const [
    {
      'username': 'Pengguna Anonim',
      'achievement': 'Mencapai Level 5!',
      'time': '2 jam yang lalu',
      'likes': 12,
    },
    {
      'username': 'Pengguna Anonim',
      'achievement': 'Menyelesaikan 7 hari rekor ketenangan.',
      'time': '5 jam yang lalu',
      'likes': 34,
    },
    {
      'username': 'Pengguna Anonim',
      'achievement':
          'Menyelesaikan semua aktivitas relaksasi untuk minggu ini.',
      'time': '1 hari yang lalu',
      'likes': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencapaian Komunitas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _mockPosts.length,
        itemBuilder: (context, index) {
          final post = _mockPosts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post['time'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post['achievement'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('${post['likes']} dukungan'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to share a milestone anonymously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dialog berbagi akan terbuka di sini.'),
            ),
          );
        },
        child: const Icon(Icons.share),
      ),
    );
  }
}
