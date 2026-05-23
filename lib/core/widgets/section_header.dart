import 'package:flutter/material.dart';
import 'package:localservicemarket/core/theme/theme_extensions.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.titleOnSurface,
            ),
          ),
          if (action != null)
            action!
          else if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel ?? 'See all'),
            ),
        ],
      ),
    );
  }
}
