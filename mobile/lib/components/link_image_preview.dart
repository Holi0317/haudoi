import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/link.dart';
import '../providers/api/api.dart';
import '../repositories/api.dart';

class LinkImagePreview extends HookConsumerWidget {
  const LinkImagePreview({
    super.key,
    required this.item,
    this.padding = const EdgeInsets.only(),
  });

  final Link item;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiRepository = ref.watch(apiRepositoryProvider);
    final hide = useState(false);

    // Whenever the URL changes, reset hide state
    // This is necessary because the same widget instance may be reused for different links
    useEffect(() {
      hide.value = false;
      return null;
    }, [item.url]);

    if (hide.value) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraint) {
        final width = max(40.0, constraint.maxWidth * 0.25);
        final height = constraint.maxHeight;

        return Padding(
          padding: padding,
          child: SizedBox(
            width: width,
            height: height,
            child: switch (apiRepository) {
              AsyncValue(:final value?, hasValue: true) => _buildImage(
                context,
                value,
                width,
                height,
                hide,
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
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Skeletonizer(
      child: ColoredBox(
        color: color,
        child: SizedBox(width: width, height: height),
      ),
    );
  }

  Widget _buildImage(
    BuildContext context,
    ApiRepository api,
    double width,
    double height,
    ValueNotifier<bool> hide,
  ) {
    final imageUrl = api.imageUrl(
      item.url,
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
          hide.value = true;
        }
      },
    );
  }
}
