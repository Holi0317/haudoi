import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/link.dart';
import '../providers/api/api.dart';
import '../repositories/api.dart';
import './shimmer.dart';

class LinkImagePreview extends ConsumerStatefulWidget {
  const LinkImagePreview({
    super.key,
    required this.item,
    this.padding = const EdgeInsets.only(),
  });

  final Link item;

  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<LinkImagePreview> createState() => _LinkImagePreviewState();
}

class _LinkImagePreviewState extends ConsumerState<LinkImagePreview> {
  bool _hide = false;

  @override
  void didUpdateWidget(covariant LinkImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.url != widget.item.url) {
      setState(() {
        _hide = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiRepository = ref.watch(apiRepositoryProvider);

    if (_hide) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraint) {
        final width = max(40.0, constraint.maxWidth * 0.25);
        final height = constraint.maxHeight;

        return Padding(
          padding: widget.padding,
          child: SizedBox(
            width: width,
            height: height,
            child: switch (apiRepository) {
              AsyncValue(:final value?, hasValue: true) => _buildImage(
                context,
                value,
                width,
                height,
              ),
              AsyncValue(error: != null) => const Icon(Icons.error),
              AsyncValue() => _buildShimmer(context, width, height),
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmer(BuildContext context, double width, double height) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildImage(
    BuildContext context,
    ApiRepository api,
    double width,
    double height,
  ) {
    final imageUrl = api.imageUrl(
      widget.item.url,
      dpr: MediaQuery.devicePixelRatioOf(context),
      width: width,
      height: height,
    );

    final headers = {
      ...api.headers,
      // Flutter's `Image` widget only supports webp. Doesn't seem to have a way to check if we support avif or not.
      "Accept": "image/webp,image/jpeg",
    };

    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: headers,
      width: width,
      height: height,
      placeholder: (context, url) => _buildShimmer(context, width, height),
      errorWidget: (context, url, error) => const SizedBox.shrink(),
      errorListener: (value) {
        if (context.mounted) {
          setState(() {
            _hide = true;
          });
        }
      },
    );
  }
}
