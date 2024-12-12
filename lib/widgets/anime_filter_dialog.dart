import 'package:flutter/material.dart';
import '../models/filter_model.dart';

class AnimeFilterDialog extends StatefulWidget {
  final AnimeFilter currentFilter;
  final List<String> availableCategories;

  const AnimeFilterDialog({
    super.key,
    required this.currentFilter,
    required this.availableCategories,
  });

  @override
  State<AnimeFilterDialog> createState() => _AnimeFilterDialogState();
}

class _AnimeFilterDialogState extends State<AnimeFilterDialog> {
  late AnimeFilter filter;

  @override
  void initState() {
    super.initState();
    filter = AnimeFilter(
      searchQuery: widget.currentFilter.searchQuery,
      categories: List.from(widget.currentFilter.categories),
      watchStatus: widget.currentFilter.watchStatus,
      minRating: widget.currentFilter.minRating,
      sortBy: widget.currentFilter.sortBy,
      sortAscending: widget.currentFilter.sortAscending,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar Animes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: filter.watchStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'watched', child: Text('Assistidos')),
                DropdownMenuItem(value: 'planned', child: Text('Planejados')),
              ],
              onChanged: (value) => setState(() => filter.watchStatus = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: filter.sortBy,
              decoration: const InputDecoration(labelText: 'Ordenar por'),
              items: const [
                DropdownMenuItem(value: 'title', child: Text('Título')),
                DropdownMenuItem(value: 'rating', child: Text('Nota')),
                DropdownMenuItem(value: 'lastWatched', child: Text('Último assistido')),
              ],
              onChanged: (value) => setState(() => filter.sortBy = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Ordem:'),
                Switch(
                  value: filter.sortAscending,
                  onChanged: (value) => setState(() => filter.sortAscending = value),
                ),
                Text(filter.sortAscending ? 'Crescente' : 'Decrescente'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: widget.availableCategories.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: filter.categories.contains(category),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        filter.categories.add(category);
                      } else {
                        filter.categories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
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
          onPressed: () => Navigator.pop(context, filter),
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}