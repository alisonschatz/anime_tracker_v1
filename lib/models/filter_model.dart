class AnimeFilter {
  String? searchQuery;
  List<String> categories;
  String? watchStatus; // 'all', 'watched', 'planned'
  double? minRating;
  String? sortBy; // 'title', 'rating', 'lastWatched'
  bool sortAscending;

  AnimeFilter({
    this.searchQuery,
    this.categories = const [],
    this.watchStatus,
    this.minRating,
    this.sortBy = 'title',
    this.sortAscending = true,
  });
}