import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'phone_verification_provider.dart';

class PhoneVerificationBanner extends StatelessWidget {
  const PhoneVerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhoneVerificationProvider>();
    if (!provider.showBanner) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isSending = provider.state == PhoneVerifState.sending;

    return Material(
      color: colorScheme.tertiaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  color: colorScheme.onTertiaryContainer, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verifica tu número de teléfono',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => provider.dismiss(),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onTertiaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Después', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 4),
              FilledButton(
                onPressed: isSending
                    ? null
                    : () => provider.codeSent
                        ? _showCodeDialog(context, provider)
                        : _showConfirmDialog(context, provider),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.tertiary,
                  foregroundColor: colorScheme.onTertiary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: isSending
                    ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colorScheme.onTertiary),
                      )
                    : const Text('Verificar ahora'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(
      BuildContext context, PhoneVerificationProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verificar número'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enviaremos un código SMS al número registrado:'),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '+52 ${provider.maskedPhone}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.sendCode();
              if (provider.codeSent && context.mounted) {
                _showCodeDialog(context, provider);
              } else if (provider.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(provider.error!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              }
            },
            child: const Text('Enviar código'),
          ),
        ],
      ),
    );
  }

  void _showCodeDialog(
      BuildContext context, PhoneVerificationProvider provider) {
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ListenableBuilder(
        listenable: provider,
        builder: (_, __) => AlertDialog(
          title: const Text('Ingresa el código'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Escribe el código de 6 dígitos que enviamos por SMS.'),
              const SizedBox(height: 16),
              TextField(
                controller: codeCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: TextStyle(
                      color: Theme.of(ctx).colorScheme.error, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: provider.state == PhoneVerifState.verifying
                  ? null
                  : () async {
                      final ok =
                          await provider.verifyCode(codeCtrl.text.trim());
                      if (ok && ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('¡Número verificado correctamente! ✓'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              child: provider.state == PhoneVerifState.verifying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}
