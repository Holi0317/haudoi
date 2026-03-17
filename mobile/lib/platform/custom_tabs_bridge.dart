import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ArchiveActionEvent {
  const ArchiveActionEvent({required this.linkId, this.url});

  final int linkId;
  final String? url;

  String get summary => 'linkId=$linkId url=${url ?? '<null>'}';
}

class CustomTabsBridge {
  CustomTabsBridge._();

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
      _log('initialize skipped: already initialized');
      return;
    }

    _isInitialized = true;
    _log('initialize register method channel handler');
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> drainPendingArchiveActions() async {
    if (!Platform.isAndroid) {
      _log('drain skipped: non-Android platform');
      return;
    }

    initialize();
    _log('drain request pending archive actions');

    try {
      final events = await _channel.invokeListMethod<dynamic>(
        'drainPendingArchiveActions',
      );
      _log('drain received count=${events?.length ?? 0}');
      for (final raw in events ?? const <dynamic>[]) {
        _emitArchiveAction(raw, source: 'drain');
      }
    } on PlatformException catch (error) {
      _log('drain failed code=${error.code} message=${error.message}');
      return;
    }
  }

  Future<bool> openLinkWithArchiveAction({
    required Uri uri,
    required int linkId,
  }) async {
    if (!Platform.isAndroid) {
      _log(
        'openLinkWithArchiveAction fallback launcher linkId=$linkId url=$uri',
      );
      return launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        webOnlyWindowName: '_blank',
      );
    }

    initialize();
    _log('openLinkWithArchiveAction invoke native linkId=$linkId url=$uri');

    try {
      await _channel.invokeMethod<void>('openLinkWithArchiveAction', {
        'url': uri.toString(),
        'linkId': linkId,
      });
      _log('openLinkWithArchiveAction native call succeeded linkId=$linkId');
      return true;
    } on PlatformException catch (error) {
      _log(
        'openLinkWithArchiveAction native call failed code=${error.code} message=${error.message}',
      );
      return false;
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    _log('method channel callback method=${call.method}');
    if (call.method != 'onArchiveAction') {
      _log('ignore unknown method channel callback method=${call.method}');
      return;
    }

    _emitArchiveAction(call.arguments, source: 'method_channel');
  }

  void _emitArchiveAction(dynamic raw, {required String source}) {
    if (raw is! Map) {
      _log(
        'drop event source=$source reason=non_map payloadType=${raw.runtimeType}',
      );
      return;
    }

    final args = Map<String, dynamic>.from(raw);
    final linkId = args['linkId'];
    if (linkId is! int) {
      _log('drop event source=$source reason=missing_link_id payload=$args');
      return;
    }

    final event = ArchiveActionEvent(
      linkId: linkId,
      url: args['url'] as String?,
    );
    _log('emit event source=$source ${event.summary}');
    _archiveActionController.add(event);
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[ArchiveFlow] $message');
    }
  }
}
