import 'package:flutter/material.dart';

/// Keeps Korean words together while honoring explicit paragraph breaks.
class WordWrapText extends StatelessWidget {
  const WordWrapText(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;
  @override
  Widget build(BuildContext context) => Semantics(
    label: text,
    excludeSemantics: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in text.split('\n'))
          Wrap(
            spacing: (style.fontSize ?? 14) * .25,
            children: [
              for (final word in line.split(' ').where((w) => w.isNotEmpty))
                Text(word, softWrap: false, style: style),
            ],
          ),
      ],
    ),
  );
}
