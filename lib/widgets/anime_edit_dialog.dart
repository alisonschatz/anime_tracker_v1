import 'package:flutter/material.dart';
import '../models/anime_model.dart';

class AnimeEditDialog extends StatefulWidget {
  final AnimeModel anime;
  final List<String> availableCategories;

  const AnimeEditDialog({
    super.key,
    required this.anime,
    required this.availableCategories,
  });

  @override
  State<AnimeEditDialog> createState() => _AnimeEditDialogState();
}

class _AnimeEditDialogState extends State<AnimeEditDialog> {
  late TextEditingController _commentController;
  late TextEditingController _episodesController;
  late List<String> selectedCategories;
  late String newCategory;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.anime.userComment);
    _episodesController = TextEditingController(
      text: widget.anime.episodesWatched?.toString() ?? '',
    );
    selectedCategories = List.from(widget.anime.categories);
    newCategory = '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Anime'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentário',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _episodesController,
              decoration: InputDecoration(
                labelText: 'Episódios assistidos',
                border: const OutlineInputBorder(),
                helperText: 'Total: ${widget.anime.episodeCount ?? "?"} episódios',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nova categoria',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => newCategory = value,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (newCategory.isNotEmpty) {
                      setState(() {
                        selectedCategories.add(newCategory);
                        newCategory = '';
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ...widget.availableCategories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: selectedCategories.contains(category),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedCategories.add(category);
                        } else {
                          selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final episodesWatched = int.tryParse(_episodesController.text);
            Navigator.pop(context, {
              'comment': _commentController.text,
              'episodesWatched': episodesWatched,
              'categories': selectedCategories,
              'lastWatched': DateTime.now(),
            });
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _episodesController.dispose();
    super.dispose();
  }
}
