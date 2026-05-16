import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/community_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  List<Map<String, dynamic>> _posts = [];
  final Set<String> _likedPosts = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _posts = context.read<CommunityService>().getCommunityPosts();
    });
  }

  void _handlePost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    await context.read<CommunityService>().addCommunityPost(text);
    _postController.clear();
    _loadPosts();
  }

  void _handleLike(String id) async {
    if (_likedPosts.contains(id)) return;

    await context.read<CommunityService>().likePost(id);
    setState(() {
      _likedPosts.add(id);
      _loadPosts();
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildPostInput(context),
                    const SizedBox(height: 24),
                    _buildPostsList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              LucideIcons.ghost,
              color: Color(0xFF818CF8),
              size: 32,
            ), // indigo-400
            const SizedBox(width: 12),
            Text(
              'Cerita Anonim',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Bagikan pencapaian atau keluh kesahmu tanpa beban, karena identitasmu 100% rahasia.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPostInput(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
        ), // indigo-500/30
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _postController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tulis cerita anonimmu hari ini...',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aman & Rahasia',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                ElevatedButton.icon(
                  onPressed: _handlePost,
                  icon: const Icon(LucideIcons.send, size: 16),
                  label: const Text('Bagikan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5), // indigo-600
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(BuildContext context) {
    return Column(
      children: _posts.map((post) {
        final isLiked = _likedPosts.contains(post['id']);
        final date = DateTime.parse(post['date']);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post['content'],
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      height: 1.5,
                    ),
                  ), // slate-200
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: isLiked ? null : () => _handleLike(post['id']),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.heart,
                          size: 20,
                          color: isLiked
                              ? const Color(0xFFF43F5E)
                              : Colors.grey,
                        ), // rose-500
                        const SizedBox(width: 6),
                        Text(
                          '${post['likes']}',
                          style: TextStyle(
                            color: isLiked
                                ? const Color(0xFFF43F5E)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
