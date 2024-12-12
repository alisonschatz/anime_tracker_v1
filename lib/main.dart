import 'package:flutter/material.dart';
import 'dart:async';
import 'models/anime_model.dart';
import 'models/filter_model.dart';
import 'services/kitsu_api_service.dart';
import 'widgets/anime_filter_dialog.dart';
import 'widgets/anime_edit_dialog.dart';
import 'widgets/anime_image.dart';

void main() {
  runApp(const AnimeTrackerApp());
}

class AnimeTrackerApp extends StatelessWidget {
  const AnimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Tracker',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final KitsuApiService _apiService = KitsuApiService();
  final List<AnimeModel> _myAnimes = [];
  final _searchController = TextEditingController();
  List<AnimeModel> _searchResults = [];
  Timer? _debounce;
  AnimeFilter _currentFilter = AnimeFilter();
  final Set<String> _allCategories = {};

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        try {
          final results = await _apiService.searchAnimes(query);
          if (mounted) {
            setState(() {
              _searchResults = results;
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao buscar animes: $e')),
            );
          }
        }
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  void _addAnimeToList(AnimeModel anime, String status) {
    setState(() {
      final newAnime = AnimeModel(
        id: anime.id,
        title: anime.title,
        posterImage: anime.posterImage,
        synopsis: anime.synopsis,
        status: status,
        averageRating: anime.averageRating,
        episodeCount: anime.episodeCount,
        releaseStatus: anime.releaseStatus,
        ageRating: anime.ageRating,
        userRating: status == 'watched' ? 0 : null,
        categories: [],
      );
      _myAnimes.add(newAnime);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${anime.title} adicionado à lista'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () {
              setState(() {
                _myAnimes.remove(newAnime);
              });
            },
          ),
        ),
      );
    });
  }

  void _updateRating(AnimeModel anime, double rating) {
    setState(() {
      final index = _myAnimes.indexWhere((a) => a.id == anime.id);
      if (index != -1) {
        _myAnimes[index].userRating = rating;
      }
    });
  }

  List<AnimeModel> _getFilteredAnimes() {
    return _myAnimes.where((anime) {
      if (_currentFilter.watchStatus != null && 
          anime.status != _currentFilter.watchStatus) {
        return false;
      }
      
      if (_currentFilter.categories.isNotEmpty &&
          !_currentFilter.categories.any((cat) => anime.categories.contains(cat))) {
        return false;
      }

      if (_currentFilter.minRating != null &&
          (anime.userRating == null || anime.userRating! < _currentFilter.minRating!)) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_currentFilter.sortBy) {
          case 'title':
            return _currentFilter.sortAscending
                ? a.title.compareTo(b.title)
                : b.title.compareTo(a.title);
          case 'rating':
            final aRating = a.userRating ?? 0;
            final bRating = b.userRating ?? 0;
            return _currentFilter.sortAscending
                ? aRating.compareTo(bRating)
                : bRating.compareTo(aRating);
          case 'lastWatched':
            final aDate = a.lastWatched ?? DateTime(1900);
            final bDate = b.lastWatched ?? DateTime(1900);
            return _currentFilter.sortAscending
                ? aDate.compareTo(bDate)
                : bDate.compareTo(aDate);
          default:
            return 0;
        }
      });
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<AnimeFilter>(
      context: context,
      builder: (context) => AnimeFilterDialog(
        currentFilter: _currentFilter,
        availableCategories: _allCategories.toList(),
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilter = result;
      });
    }
  }

  Future<void> _editAnime(AnimeModel anime) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AnimeEditDialog(
        anime: anime,
        availableCategories: _allCategories.toList(),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _myAnimes.indexWhere((a) => a.id == anime.id);
        if (index != -1) {
          _myAnimes[index].userComment = result['comment'];
          _myAnimes[index].episodesWatched = result['episodesWatched'];
          _myAnimes[index].categories = List<String>.from(result['categories']);
          _myAnimes[index].lastWatched = result['lastWatched'];
          
          _allCategories.addAll(_myAnimes[index].categories);
        }
      });
    }
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      if (_searchController.text.isEmpty) {
        return const Center(
          child: Text('Digite algo para buscar animes'),
        );
      }
      return const Center(
        child: Text('Nenhum anime encontrado'),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final anime = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
                child: AnimeImage(
                  imageUrl: anime.posterImage ?? '',
                  width: 70,
                  height: 105,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        anime.synopsis,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (anime.episodeCount != null) ...[
                            Icon(
                              Icons.playlist_play,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${anime.episodeCount} eps',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (anime.averageRating != null) ...[
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              anime.averageRating!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.add),
                tooltip: 'Adicionar à lista',
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'watched',
                    child: Text('Já Assisti'),
                  ),
                  const PopupMenuItem(
                    value: 'planned',
                    child: Text('Quero Assistir'),
                  ),
                ],
                onSelected: (status) => _addAnimeToList(anime, status),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimeList(String status) {
    final filteredAnimes = _getFilteredAnimes()
        .where((anime) => anime.status == status)
        .toList();
    
    if (filteredAnimes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'watched' ? Icons.check_circle : Icons.pending,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'watched'
                  ? 'Nenhum anime assistido ainda'
                  : 'Nenhum anime na lista de planejados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredAnimes.length,
      itemBuilder: (context, index) {
        final anime = filteredAnimes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(4),
                    ),
                    child: AnimeImage(
                      imageUrl: anime.posterImage ?? '',
                      width: 70,
                      height: 105,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anime.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            anime.synopsis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          if (anime.episodeCount != null)
                            Text(
                              'Episódios: ${anime.episodesWatched ?? 0}/${anime.episodeCount}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (anime.averageRating != null)
                            Text(
                              'Nota média: ${anime.averageRating!.toStringAsFixed(1)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        onPressed: () => _editAnime(anime),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Remover da lista',
                        onPressed: () {
                          setState(() {
                            _myAnimes.remove(anime);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (anime.categories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: anime.categories.map((category) {
                      return Chip(
                        label: Text(
                          category,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onDeleted: () {
                          setState(() {
                            anime.categories.remove(category);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              if (anime.userComment?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comentário:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        anime.userComment!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              if (status == 'watched') ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: anime.userRating ?? 0,
                              min: 0,
                              max: 10,
                              divisions: 10,
                              label: (anime.userRating ?? 0).toStringAsFixed(1),
                              onChanged: (value) => _updateRating(anime, value),
                            ),
                          ),
                          Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(anime.userRating ?? 0).toStringAsFixed(1)}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (anime.lastWatched != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Último episódio: ${_formatDate(anime.lastWatched!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Animes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar anime',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.purple,
                      tabs: [
                        Tab(text: 'Busca'),
                        Tab(text: 'Assistidos'),
                        Tab(text: 'Planejados'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildSearchResults(),
                          _buildAnimeList('watched'),
                          _buildAnimeList('planned'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}