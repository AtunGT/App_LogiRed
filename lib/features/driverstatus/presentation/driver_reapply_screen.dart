import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_service.dart';
import 'driver_reapply_provider.dart';

/// Reenvio de documentos para un conductor rechazado.
///
/// Muestra todo lo que se puede corregir, pero no obliga a nada: el conductor
/// adjunta solo aquello que administracion le señalo en el motivo del rechazo.
class DriverReapplyScreen extends StatelessWidget {
  const DriverReapplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => DriverReapplyProvider(c.read<ApiService>()),
      child: const _DriverReapplyView(),
    );
  }
}

class _DriverReapplyView extends StatelessWidget {
  const _DriverReapplyView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<DriverReapplyProvider>(
      builder: (context, provider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.success && Navigator.canPop(context)) {
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
              'Corregir documentos',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text(
                'Adjunta unicamente lo que necesitas corregir. Lo que no envies '
                'se conserva tal como lo tenemos.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Documentos',
                child: _FileList(
                  fields: kReapplyDocuments,
                  provider: provider,
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Fotos del vehiculo',
                child: _FileList(
                  fields: kReapplyVehiclePhotos,
                  provider: provider,
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Foto de perfil',
                child: _FileList(
                  fields: const [kReapplyProfilePhoto],
                  provider: provider,
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Datos del vehiculo',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    children: [
                      for (final entry in kReapplyTextFields.entries) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: provider.textOf(entry.key),
                          onChanged: (v) => provider.setText(entry.key, v),
                          keyboardType: entry.key == 'max_capacity'
                              ? TextInputType.number
                              : TextInputType.text,
                          decoration: InputDecoration(
                            labelText: entry.value,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style:
                      textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: provider.isLoading ? null : provider.submit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          provider.hasChanges
                              ? 'Enviar ${provider.changeCount} cambio'
                                  '${provider.changeCount == 1 ? '' : 's'}'
                              : 'Enviar para revision',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _FileList extends StatelessWidget {
  final List<ReapplyField> fields;
  final DriverReapplyProvider provider;

  const _FileList({required this.fields, required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(fields.length, (i) {
        final field = fields[i];
        final path = provider.pathOf(field.apiKey);
        final isLast = i == fields.length - 1;

        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: path == null
                  ? Icon(Icons.photo_camera_outlined,
                      color: colorScheme.onSurfaceVariant)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(path),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
              title: Text(
                field.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                path == null ? 'Sin cambios' : 'Listo para enviar',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: path == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                    ),
              ),
              trailing: path == null
                  ? TextButton(
                      onPressed: () => provider.pick(field),
                      child: const Text('Adjuntar'),
                    )
                  : IconButton(
                      icon: Icon(Icons.close,
                          color: colorScheme.onSurfaceVariant),
                      onPressed: () => provider.remove(field),
                    ),
              onTap: path == null ? () => provider.pick(field) : null,
            ),
            if (!isLast)
              Divider(
                height: 1,
                indent: 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
          ],
        );
      }),
    );
  }
}
