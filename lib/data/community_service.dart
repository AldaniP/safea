import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class CommunityService extends ChangeNotifier {
  static const String _key = 'safea_community_posts';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Map<String, dynamic>> getCommunityPosts() {
    final data = _prefs?.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    final defaultPosts = [
      {
        'id': 'post1',
        'date': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'content':
            'Hari ini berhasil bangun pagi dan jalan santai selama 15 menit. Terlihat remeh, tapi ini kemenangan besar buat saya setelah minggu yang berat.',
        'likes': 24,
      },
      {
        'id': 'post2',
        'date': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
        'content':
            'Coba teknik grounding 5-4-3-2-1 saat panic attack tadi di kantor. Agak sulit awalnya, tapi benar-benar membantu saya kembali fokus.',
        'likes': 18,
      },
      {
        'id': 'post3',
        'date': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'content':
            'Akhirnya memberanikan diri untuk membuat janji dengan psikolog. Takut, tapi saya tahu ini langkah yang tepat.',
        'likes': 56,
      },
    ];
    saveCommunityPosts(defaultPosts);
    return defaultPosts;
  }

  Future<void> saveCommunityPosts(
    List<Map<String, dynamic>> posts,
  ) async {
    await _prefs?.setString(_key, jsonEncode(posts));
    notifyListeners();
  }

  Future<void> addCommunityPost(String content) async {
    final posts = getCommunityPosts();
    final newPost = {
      'id': Random().nextInt(1000000).toString(),
      'date': DateTime.now().toIso8601String(),
      'content': content,
      'likes': 0,
    };
    posts.insert(0, newPost);
    await saveCommunityPosts(posts);
  }

  Future<void> likePost(String id) async {
    final posts = getCommunityPosts();
    final index = posts.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      posts[index]['likes'] = (posts[index]['likes'] as int) + 1;
      await saveCommunityPosts(posts);
    }
  }
}
