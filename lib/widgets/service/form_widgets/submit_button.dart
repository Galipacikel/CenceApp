import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cence_app/features/service_history/application/new_service_form_notifier.dart';

class SubmitButton extends ConsumerWidget {
  const SubmitButton({super.key, this.onSubmit});

  final Future<void> Function()? onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newServiceFormProvider);
    final notifier = ref.read(newServiceFormProvider.notifier);

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF23408E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: state.isSaving
            ? null
            : () async {
                try {
                  if (onSubmit != null) {
                    await notifier.submitWithAction(onSubmit!);
                  } else {
                    await notifier.submitForm();
                  }
                } catch (_) {
                  // Hata bildirimi çağıran tarafa bırakılabilir
                }
              },
        child: state.isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Kaydediliyor...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : const Text(
                'Kaydet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}