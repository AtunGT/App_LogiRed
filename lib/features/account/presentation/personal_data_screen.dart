import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/model/models.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  UserResponse? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  XFile? _pickedImage;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _lastnameCtrl;
  late final TextEditingController _birthdateCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _lastnameCtrl = TextEditingController();
    _birthdateCtrl = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastnameCtrl.dispose();
    _birthdateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final res = await sl.apiService.getMe();
      final user = UserResponse.fromJson(res.data);
      setState(() {
        _user = user;
        _nameCtrl.text = user.name;
        _lastnameCtrl.text = user.lastname;
        _birthdateCtrl.text = _toDisplay(user.birthdate);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _toDisplay(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parts = raw.split('T').first.split('-');
      if (parts.length < 3) return raw;
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    } catch (_) {
      return raw;
    }
  }

  String _toApi(String display) {
    try {
      final parts = display.split('/');
      if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
    } catch (_) {}
    return display;
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _pickedImage = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final map = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'lastname': _lastnameCtrl.text.trim(),
        'birthdate': _toApi(_birthdateCtrl.text.trim()),
      };
      if (_pickedImage != null) {
        map['image'] = await MultipartFile.fromFile(
          _pickedImage!.path,
          filename: _pickedImage!.name,
        );
      }
      await sl.apiService.updateUser(FormData.fromMap(map));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar los cambios')),
        );
      }
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          'Datos personales',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: colorScheme.primary,
                          backgroundImage: _pickedImage != null
                              ? FileImage(File(_pickedImage!.path))
                              : _user?.imageUrl != null
                                  ? CachedNetworkImageProvider(_user!.imageUrl!)
                                      as ImageProvider
                                  : null,
                          child:
                              (_pickedImage == null && _user?.imageUrl == null)
                                  ? Text(
                                      _user != null && _user!.name.isNotEmpty
                                          ? _user!.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 34,
                                      ),
                                    )
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _pickPhoto,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            foregroundColor: colorScheme.primary,
                          ),
                          child: const Text('Cambiar foto',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FieldBlock(
                    label: 'Nombre',
                    controller: _nameCtrl,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 14),
                  _FieldBlock(
                    label: 'Apellido',
                    controller: _lastnameCtrl,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 14),
                  _FieldBlock(
                    label: 'Fecha de nacimiento',
                    controller: _birthdateCtrl,
                    colorScheme: colorScheme,
                    hint: 'DD/MM/AAAA',
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ColorScheme colorScheme;
  final String? hint;
  final TextInputType? keyboardType;

  const _FieldBlock({
    required this.label,
    required this.controller,
    required this.colorScheme,
    this.hint,
    this.keyboardType,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }
}
