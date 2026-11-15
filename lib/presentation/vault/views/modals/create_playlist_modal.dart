import 'package:flutter/material.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../bloc/vault_bloc.dart';

class CreatePlaylistModal extends StatefulWidget {
  final VaultBloc vaultBloc;

  const CreatePlaylistModal({super.key, required this.vaultBloc});

  @override
  State<CreatePlaylistModal> createState() => _CreatePlaylistModalState();
}

class _CreatePlaylistModalState extends State<CreatePlaylistModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.length < 3) {
      setState(() {
        _titleError = 'Playlist title must be at least 3 characters';
      });
      return;
    }

    widget.vaultBloc.add(
      CreatePlaylistEvent(
        title: title,
        description: desc.isEmpty ? 'Custom audiophile playlist' : desc,
      ),
    );

    Navigator.of(context).pop();
    AppFeedback.showSuccess(
      context,
      'Custom playlist "$title" created successfully.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Create Custom Playlist',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Curate lossless tracks and technical podcast episodes into personal queues.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _titleController,
                autofocus: true,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Playlist Title',
                  hintText: 'e.g., Compilers & Low-Level Code',
                  errorText: _titleError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: _descController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g., Deep focus sessions for systems engineering',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.playlist_add_rounded),
                  label: const Text('Create Playlist'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
