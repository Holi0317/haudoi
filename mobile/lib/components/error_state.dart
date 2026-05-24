import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';
import '../repositories/api_error.dart';

/// Reusable UI for rendering an error message with optional action buttons.
class ErrorState extends StatelessWidget {
  /// Creates an error-state widget.
  ///
  /// A retry button is shown only when [onRetry] is provided.
  /// A secondary action button is shown only when both
  /// [onSecondaryAction] and [secondaryActionLabel] are provided.
  const ErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.compact = false,
  });

  /// Error object used to render a user-facing message.
  /// There is special handling for [ApiError] to show a more user-friendly message.
  final Object error;

  /// Callback for the primary retry action.
  final VoidCallback? onRetry;

  /// Callback for an optional secondary action.
  ///
  /// Effective only when [secondaryActionLabel] is also provided.
  final VoidCallback? onSecondaryAction;

  /// Label for the optional secondary action button.
  ///
  /// Effective only when [onSecondaryAction] is also provided.
  final String? secondaryActionLabel;

  /// Whether to render a denser variant with smaller icon/text spacing.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttons = <Widget>[
      if (onRetry != null)
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(t.retry),
        ),
      if (onSecondaryAction != null && secondaryActionLabel != null)
        OutlinedButton(
          onPressed: onSecondaryAction,
          child: Text(secondaryActionLabel!),
        ),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: compact ? 36 : 48,
            ),
            SizedBox(height: compact ? 8 : 16),
            Text(
              _messageFor(error),
              textAlign: TextAlign.center,
              style: compact
                  ? theme.textTheme.bodyMedium
                  : theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showErrorDetailsDialog(context, error),
              icon: const Icon(Icons.info_outline),
              label: const Text('Details'),
            ),
            if (buttons.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: buttons,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _messageFor(Object error) {
    if (error case ApiError()) {
      return error.userMessage();
    }

    return error.toString();
  }

  Future<void> _showErrorDetailsDialog(BuildContext context, Object error) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error details'),
        content: SingleChildScrollView(
          child: SelectableText(
            'Type: ${error.runtimeType}\n\n$error',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.dialogs.close),
          ),
        ],
      ),
    );
  }
}
