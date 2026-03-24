import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

final _logger = Logger("CustomTabsBridge");

class ArchiveActionEvent {
  const ArchiveActionEvent({required this.linkId, this.url});

  final int linkId;
  final String? url;

  String get summary => 'linkId=$linkId url=${url ?? '<null>'}';

  /// Try decode an [ArchiveActionEvent] from the raw native event payload.
  static ArchiveActionEvent? fromNative(dynamic raw) {
    if (raw is! Map) {
      _logger.warning(
        'drop event reason=non_map payloadType=${raw.runtimeType}',
      );
      return null;
    }

    final args = Map<String, dynamic>.from(raw);
    final linkId = args['linkId'];
    if (linkId is! int) {
      _logger.warning('drop event reason=missing_link_id payload=$args');
      return null;
    }

    final event = ArchiveActionEvent(
      linkId: linkId,
      url: args['url'] as String?,
    );
    _logger.info('decoded event ${event.summary}');
    return event;
  }
}

/// Native bridge for Android custom tabs (browser) and archive action callbacks.
///
/// GH-115: Implement iOS support
///
/// See ArchiveActionSupport.kt for the design.
class CustomTabsBridge {
  CustomTabsBridge._();

  static final CustomTabsBridge instance = CustomTabsBridge._();

  static const _channel = MethodChannel(
    'com.github.holi0317.haudoi/custom_tabs',
  );

  /// Read and clear pending archive actions from the native side.
  ///
  /// If this failed (e.g. non-Android platform or native call failure), it returns an empty list and logs the error.
  Future<List<ArchiveActionEvent>> drainPendingArchiveActions() async {
    if (!Platform.isAndroid) {
      _logger.fine('drain skipped: non-Android platform');
      return [];
    }

    // See ArchiveActionSupport.kt for the native side of this queue-and-drain flow.
    _logger.fine('drain request pending archive actions');

    try {
      final events = await _channel.invokeListMethod<dynamic>(
        'drainPendingArchiveActions',
      );
      _logger.fine('drain received count=${events?.length ?? 0}');

      return (events ?? [])
          .map(ArchiveActionEvent.fromNative)
          .nonNulls
          .toList();
    } on PlatformException catch (error) {
      _logger.fine('drain failed code=${error.code} message=${error.message}');
      return [];
    }
  }

  Future<bool> openLink({
    required Uri uri,
    required int linkId,
    required bool archiveButton,
  }) async {
    if (!Platform.isAndroid) {
      _logger.fine('openLink fallback launcher linkId=$linkId url=$uri');
      return launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        webOnlyWindowName: '_blank',
      );
    }

    _logger.info('openLink invoke native linkId=$linkId url=$uri');

    try {
      await _channel.invokeMethod<void>('openLink', {
        'url': uri.toString(),
        'linkId': linkId,
        'archiveButton': archiveButton,
      });
      _logger.fine('openLink native call succeeded linkId=$linkId');
      return true;
    } on PlatformException catch (error, st) {
      _logger.warning('openLink native call failed', error, st);
      return false;
    }
  }
}
