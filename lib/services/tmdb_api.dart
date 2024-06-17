// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class TMDBApi {
//   final String bearerToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMjQ0YjA3N2Y0YmZiMzQ4MDFmNWIwYjQyMTYwMjliYyIsInN1YiI6IjY2NmU3NjJiYzlmN2Q3MzVmZGM0YzFhNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.9nE5IDYH236ZVuugAkrxa2TOlA8CH_060hvTmWV3Rj8';

//   Future<List<dynamic>> fetchNews(int page) async {
//     final url = 'https://api.themoviedb.org/3/movie/popular?page=$page';
//     print('Requesting URL: $url');
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer $bearerToken',
//       },
//     );

//     if (response.statusCode == 200) {
//       print('Response received: ${response.body}');
//       return json.decode(response.body)['results'];
//     } else {
//       print('Failed to load news. Status code: ${response.statusCode}');
//       throw Exception('Failed to load news');
//     }
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBApi {
  final String bearerToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMjQ0YjA3N2Y0YmZiMzQ4MDFmNWIwYjQyMTYwMjliYyIsInN1YiI6IjY2NmU3NjJiYzlmN2Q3MzVmZGM0YzFhNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.9nE5IDYH236ZVuugAkrxa2TOlA8CH_060hvTmWV3Rj8';

  Future<List<dynamic>> fetchNews(int page) async {
    final url = 'https://api.themoviedb.org/3/movie/popular?page=$page';
    print('Requesting URL: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
      },
    );

    if (response.statusCode == 200) {
      print('Response received: ${response.body}');
      return json.decode(response.body)['results'];
    } else {
      print('Failed to load news. Status code: ${response.statusCode}');
      throw Exception('Failed to load news');
    }
  }
}
