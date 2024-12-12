import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';

class KitsuApiService {
  static const String baseUrl = 'https://kitsu.io/api/edge';

  Future<List<AnimeModel>> searchAnimes(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anime?filter[text]=$query&page[limit]=20'),
        headers: {
          'Accept': 'application/vnd.api+json',
          'Content-Type': 'application/vnd.api+json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((anime) => AnimeModel.fromJson(anime, 'planned'))
            .toList();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Falha ao buscar animes');
      }
    } catch (e) {
      print('Exception during API call: $e');
      rethrow;
    }
  }
}