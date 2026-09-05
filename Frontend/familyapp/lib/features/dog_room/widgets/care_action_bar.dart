import 'package:flutter/material.dart';

import '../controllers/dog_controller.dart';

class CareActionBar extends StatelessWidget {
  const CareActionBar({super.key, required this.onAction, this.enabled = true});

  final ValueChanged<CareAction> onAction;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Row(
          children: [
            _CareButton(
              icon: Icons.restaurant,
              label: '밥 주기',
              onPressed: enabled ? () => onAction(CareAction.feed) : null,
            ),
            _CareButton(
              icon: Icons.bathtub,
              label: '목욕',
              onPressed: enabled ? () => onAction(CareAction.wash) : null,
            ),
            _CareButton(
              icon: Icons.sports_baseball,
              label: '놀기',
              onPressed: enabled ? () => onAction(CareAction.play) : null,
            ),
            _CareButton(
              icon: Icons.bedtime,
              label: '재우기',
              onPressed: enabled ? () => onAction(CareAction.sleep) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CareButton extends StatelessWidget {
  const _CareButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
