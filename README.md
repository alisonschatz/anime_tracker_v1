# Anime Tracker v1

Um aplicativo Flutter para gerenciar animes assistidos e planejados, utilizando a API do Kitsu.

## Funcionalidades

- Busca de animes em tempo real
- Lista de animes assistidos e planejados
- Sistema de avaliação (0-10)
- Comentários personalizados
- Categorização por tags
- Sistema de filtros e ordenação

## Tecnologias

- Flutter
- Dart
- Kitsu API

## Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/anime_tracker_v1.git

# Entre no diretório
cd anime_tracker_v1

# Instale as dependências
flutter pub get

# Execute o projeto
flutter run
```

## Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  cached_network_image: ^3.3.1
```

## Estrutura

```
lib/
  ├── models/
  ├── services/
  ├── widgets/
  └── main.dart
```

## API

O projeto utiliza a [API do Kitsu](https://kitsu.docs.apiary.io/) para informações dos animes.
