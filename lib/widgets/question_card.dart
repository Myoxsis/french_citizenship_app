import 'package:flutter/material.dart';
import '../models/question.dart';
import '../theme_extensions.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.prompt,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...List.generate(question.choices.length, (i) {
              final status =
                  Theme.of(context).extension<StatusColors>()!;
              final isAnswered = selectedIndex != null;
              final isSelected = selectedIndex == i;
              final isCorrect = question.answerIndex == i;

              Color borderColor = Theme.of(context).dividerColor;
              Color? fillColor;
              Color activeColor = Theme.of(context).colorScheme.primary;

              if (isAnswered) {
                if (isCorrect) {
                  borderColor = status.success;
                  fillColor = status.success.withOpacity(0.1);
                  activeColor = status.success;
                } else if (isSelected) {
                  borderColor = status.error;
                  fillColor = status.error.withOpacity(0.1);
                  activeColor = status.error;
                }
              } else if (isSelected) {
                borderColor = Theme.of(context).colorScheme.primary;
                fillColor = Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1);
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: fillColor,
                  border: Border.all(color: borderColor),
                ),
                child: RadioListTile<int>(
                  value: i,
                  groupValue: selectedIndex,
                  onChanged:
                      isAnswered ? null : (val) => onSelected(val!),
                  title: Text(question.choices[i]),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: activeColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
