import 'package:flutter/material.dart';

class AnimeImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const AnimeImage({
    super.key,
    required this.imageUrl,
    this.width = 70,
    this.height = 105,
  });

  String _getProxyUrl(String url) {
    // Usando um serviço de proxy alternativo
    final encodedUrl = Uri.encodeComponent(url);
    return 'https://images.weserv.nl/?url=$encodedUrl';
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    final proxiedUrl = _getProxyUrl(imageUrl!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          proxiedUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error for URL: $proxiedUrl');
            return _buildPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 30,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}