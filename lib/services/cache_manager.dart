import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  Future<void> saveNews(List<dynamic> news) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cached_news', jsonEncode(news));
  }

  Future<List<dynamic>> getCachedNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newsJson = prefs.getString('cached_news');
    if (newsJson != null) {
      return jsonDecode(newsJson);
    } else {
      return [];
    }
  }
}
