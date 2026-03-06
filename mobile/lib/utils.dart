import 'dart:ui';

/// Check if a given string is a valid web URI (http or https).
///
/// Returns the parsed Uri if valid, otherwise returns null.
Uri? isWebUri(String uri) {
  final parsed = Uri.tryParse(uri);
  if (parsed == null) {
    return null;
  }

  if (parsed.scheme != 'http' && parsed.scheme != 'https') {
    return null;
  }

  return parsed;
}

/// Format a unix epoch timestamp (in milliseconds) as a relative date string.
///
/// Examples: "2 hours ago", "3 days ago", "2 months ago"
/// FIXME: Translation
String formatRelativeDate(int createdAtMs) {
  final createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtMs);
  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.isNegative) {
    return 'in the future';
  } else if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '${months}mo ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '${years}y ago';
  }
}

/// Convert a CSS hex color string (e.g. "#RRGGBB") to a Flutter [Color] object.
///
/// Assumes the input is always in the format "#RRGGBB". If the input is invalid, this will throw a [FormatException].
///
/// Should be safe for our use case since the server have strong validation for tag colors.
///
/// Ref: https://stackoverflow.com/a/57516443
Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
