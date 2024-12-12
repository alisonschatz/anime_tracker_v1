class AnimeModel {
  final String id;
  final String title;
  final String? posterImage;
  final String synopsis;
  final String status;
  final double? averageRating;
  final int? episodeCount;
  final String? releaseStatus;
  final String? ageRating;
  double? userRating;
  String? userComment;
  List<String> categories;
  int? episodesWatched;
  DateTime? lastWatched;

  AnimeModel({
    required this.id,
    required this.title,
    this.posterImage,
    required this.synopsis,
    required this.status,
    this.averageRating,
    this.userRating,
    this.episodeCount,
    this.releaseStatus,
    this.ageRating,
    this.userComment,
    this.categories = const [],
    this.episodesWatched,
    this.lastWatched,
  });

  factory AnimeModel.fromJson(Map<String, dynamic> json, String status) {
    final attributes = json['attributes'];
    final Map<String, dynamic>? posterImage = attributes['posterImage'];
    
    String? imageUrl;
    if (posterImage != null) {
                imageUrl = posterImage['tiny'] ?? 
                posterImage['small'] ?? 
                posterImage['medium'] ?? 
                posterImage['large'] ?? 
                posterImage['original'];
    }
    
    return AnimeModel(
      id: json['id'],
      title: attributes['canonicalTitle'] ?? 
             attributes['titles']['en_jp'] ?? 
             attributes['titles']['en'] ?? 
             'Sem título',
      posterImage: imageUrl,
      synopsis: attributes['synopsis'] ?? 'Sem sinopse disponível',
      status: status,
      averageRating: attributes['averageRating'] != null 
          ? double.parse(attributes['averageRating']) / 10
          : null,
      episodeCount: attributes['episodeCount'],
      releaseStatus: attributes['status'],
      ageRating: attributes['ageRating'],
      categories: [],
    );
  }
}