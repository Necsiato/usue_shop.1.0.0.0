import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:usue_app_front/config/app_config.dart';

class MediaImage extends StatelessWidget {
  const MediaImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) {
      return Container(color: Colors.black12, width: width, height: height);
    }
    if (source.startsWith('data:image')) {
      final data = UriData.parse(source);
      final Uint8List bytes = data.contentAsBytes();
      return Image.memory(bytes, fit: fit, width: width, height: height);
    }
    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined),
      );
    }
    if (source.startsWith('/')) {
      final uri = '${AppConfig.backendOrigin}$source';
      return Image.network(
        uri,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined),
      );
    }
    if (source.startsWith('assets/')) {
      final normalized =
          source.replaceFirst(RegExp(r'^assets/(images/)?'), '/static/media/');
      final uri = '${AppConfig.backendOrigin}$normalized';
      return Image.network(
        uri,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined),
      );
    }
    return Container(color: Colors.black26, width: width, height: height);
  }
}
