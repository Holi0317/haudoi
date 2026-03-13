import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ArchiveActionEvent {
  const ArchiveActionEvent({required this.linkId, this.url});

  final int linkId;
  final String? url;
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
      return;
    }

    _isInitialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<bool> openLinkWithArchiveAction({
    required Uri uri,
    required int linkId,
  }) async {
    if (!Platform.isAndroid) {
      return launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
        webOnlyWindowName: '_blank',
      );
    }

    initialize();

    try {
      await _channel.invokeMethod<void>('openLinkWithArchiveAction', {
        'url': uri.toString(),
        'linkId': linkId,
      });
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'onArchiveAction') {
      return;
    }

    final raw = call.arguments;
    if (raw is! Map) {
      return;
    }

    final args = Map<String, dynamic>.from(raw);
    final linkId = args['linkId'];
    if (linkId is! int) {
      return;
    }

    _archiveActionController.add(
      ArchiveActionEvent(linkId: linkId, url: args['url'] as String?),
    );
  }
}
