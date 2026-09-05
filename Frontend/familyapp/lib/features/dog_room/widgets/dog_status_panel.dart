import 'package:flutter/material.dart';

import '../models/dog_state.dart';

class DogStatusPanel extends StatelessWidget {
  const DogStatusPanel({super.key, required this.state});

  final DogState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '${state.stage.label} 포메 · Lv.${state.level}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.favorite, color: Color(0xFFE86A76), size: 18),
                const SizedBox(width: 4),
                Text('${state.affection}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatusItem(
                    icon: Icons.restaurant,
                    label: '배부름',
                    value: state.hunger,
                    color: const Color(0xFFF2A65A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusItem(
                    icon: Icons.water_drop,
                    label: '청결',
                    value: state.cleanliness,
                    color: const Color(0xFF68B9D8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatusItem(
                    icon: Icons.sentiment_very_satisfied,
                    label: '행복',
                    value: state.happiness,
                    color: const Color(0xFFF1C453),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusItem(
                    icon: Icons.bolt,
                    label: '체력',
                    value: state.energy,
                    color: const Color(0xFF77B77A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (state.stage == GrowthStage.adult) ...[
              Row(
                children: [
                  const Icon(Icons.card_giftcard, size: 17),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Lv.${state.level + 1} 보상 · ${state.nextAdultReward!.label}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: state.stage == GrowthStage.adult
                        ? state.levelProgress.clamp(0, 1)
                        : state.stageProgress.clamp(0, 1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  state.nextStageText,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value점',
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
              const Spacer(),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            color: color,
            backgroundColor: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
