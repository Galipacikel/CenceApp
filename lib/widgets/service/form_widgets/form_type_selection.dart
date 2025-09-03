import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';

class FormTypeSelection extends ConsumerWidget {
  const FormTypeSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formType = ref.watch(newServiceFormProvider).formTipi;
    final notifier = ref.read(newServiceFormProvider.notifier);

    return Row(
      children: [
        _FormTypeChip(
          label: 'Kurulum',
          selected: formType == 0,
          color: const Color(0xFF23408E),
          onTap: () => notifier.setFormType(0),
        ),
        const SizedBox(width: 8),
        _FormTypeChip(
          label: 'Arıza',
          selected: formType != 0, // only two types now: kurulum or arıza
          color: const Color(0xFFE53935),
          onTap: () => notifier.setFormType(1),
        ),
      ],
    );
  }
}

class _FormTypeChip extends StatelessWidget {
  const _FormTypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
