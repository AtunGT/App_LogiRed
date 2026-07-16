import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'change_password_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => ChangePasswordProvider(),
      child: Consumer<ChangePasswordProvider>(
        builder: (context, provider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contraseña actualizada')),
              );
              Navigator.pop(context);
            }
          });

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Cambiar contraseña',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PasswordField(
                    label: 'Contraseña actual',
                    controller: _oldCtrl,
                    visible: _showOld,
                    onToggle: () => setState(() => _showOld = !_showOld),
                    onChanged: provider.onOldChange,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    label: 'Nueva contraseña',
                    controller: _newCtrl,
                    visible: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                    onChanged: provider.onNewChange,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    label: 'Confirmar nueva contraseña',
                    controller: _confirmCtrl,
                    visible: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    onChanged: provider.onConfirmChange,
                    colorScheme: colorScheme,
                  ),
                  if (provider.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      provider.error!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: provider.isLoading ? null : provider.save,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: provider.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              'Cambiar contraseña',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;
  final void Function(String) onChanged;
  final ColorScheme colorScheme;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.visible,
    required this.onToggle,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !visible,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            suffixIcon: IconButton(
              icon: Icon(
                visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
