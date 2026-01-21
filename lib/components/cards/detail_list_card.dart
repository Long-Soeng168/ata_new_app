import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailListCard extends StatelessWidget {
  const DetailListCard({
    super.key,
    required this.keyword,
    required this.value,
    this.isCopyable = false,
  });

  final String keyword;
  final String value;
  final bool isCopyable;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $keyword'),
        behavior: SnackBarBehavior.floating,
        width: 200,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: Row(
        // Changed to center so icon and keyword align with the value
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Keyword
          SizedBox(
            width: 100,
            child: Text(
              keyword,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline,
              ),
            ),
          ),

          /// Value
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              // If you want it to be copyable, we keep it simple here
              // and let the button handle the action
            ),
          ),

          /// Copy Button
          if (isCopyable) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _copyToClipboard(context),
              icon: const Icon(Icons.copy_rounded),
              iconSize: 18,
              color: theme.colorScheme.primary,
              visualDensity: VisualDensity.compact, // Removes extra padding
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), // Tightens the hit area
            ),
          ] else
            const SizedBox(width: 18), // Match the icon size for spacing
        ],
      ),
    );
  }
}
