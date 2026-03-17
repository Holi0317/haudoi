import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

class ArchiveActionEvent {
  const ArchiveActionEvent({required this.linkId, this.url});

  final int linkId;
  final String? url;

  String get summary => 'linkId=$linkId url=${url ?? '<null>'}';
}

/// Native bridge for Android custom tabs (browser) and archive action callbacks.
///
/// GH-115: Implement iOS support
///
/// See ArchiveActionSupport.kt for the design.
class CustomTabsBridge {
  CustomTabsBridge._();

  static final _logger = Logger("CustomTabsBridge");

  static final CustomTabsBridge instance = CustomTabsBridge._();

  static const _channel = MethodChannel(
    'com.github.holi0317.haudoi/custom_tabs',
  );

  final _archiveActionController =
      StreamController<ArchiveActionEvent>.broadcast();
  bool _isInitialized = false;

  Stream<ArchiveActionEvent> get archiveActions =>
      _archiveActionController.stream;

  void initialize() {
    if (_isInitialized) {
      _logger.fine('initialize skipped: already initialized');
      return;
    }

    // Android owns the callback entrypoint. Flutter only needs to install the
    // channel handler once, then drain the persisted queue when appropriate.
    _isInitialized = true;
    _logger.info('initialize register method channel handler');
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> drainPendingArchiveActions() async {
    if (!Platform.isAndroid) {
      _logger.fine('drain skipped: non-Android platform');
      return;
    }

    initialize();
    // See ArchiveActionSupport.kt for the native side of this queue-and-drain flow.
    _logger.fine('drain request pending archive actions');

    try {
      final events = await _channel.invokeListMethod<dynamic>(
        'drainPendingArchiveActions',
      );
      _logger.fine('drain received count=${events?.length ?? 0}');
      for (final raw in events ?? const <dynamic>[]) {
        _emitArchiveAction(raw, source: 'drain');
      }
    } on PlatformException catch (error) {
      _logger.fine('drain failed code=${error.code} message=${error.message}');
      return;
    }
  }

  Future<bool> openLinkWithArchiveAction({
    required Uri uri,
    required int linkId,
  }) async {
    if (!Platform.isAndroid) {
      _logger.fine(
        'openLinkWithArchiveAction fallback launcher linkId=$linkId url=$uri',
      );
      return launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        webOnlyWindowName: '_blank',
      );
    }

    initialize();
    _logger.info(
      'openLinkWithArchiveAction invoke native linkId=$linkId url=$uri',
    );

    try {
      await _channel.invokeMethod<void>('openLinkWithArchiveAction', {
        'url': uri.toString(),
        'linkId': linkId,
      });
      _logger.fine(
        'openLinkWithArchiveAction native call succeeded linkId=$linkId',
      );
      return true;
    } on PlatformException catch (error, st) {
      _logger.warning(
        'openLinkWithArchiveAction native call failed',
        error,
        st,
      );
      return false;
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    _logger.fine('method channel callback method=${call.method}');
    if (call.method != 'onArchiveAction') {
      _logger.warning(
        'ignore unknown method channel callback method=${call.method}',
      );
      return;
    }

    _emitArchiveAction(call.arguments, source: 'method_channel');
  }

  void _emitArchiveAction(dynamic raw, {required String source}) {
    if (raw is! Map) {
      _logger.warning(
        'drop event source=$source reason=non_map payloadType=${raw.runtimeType}',
      );
      return;
    }

    final args = Map<String, dynamic>.from(raw);
    final linkId = args['linkId'];
    if (linkId is! int) {
      _logger.warning(
        'drop event source=$source reason=missing_link_id payload=$args',
      );
      return;
    }

    final event = ArchiveActionEvent(
      linkId: linkId,
      url: args['url'] as String?,
    );
    _logger.info('emit event source=$source ${event.summary}');
    _archiveActionController.add(event);
  }
}
