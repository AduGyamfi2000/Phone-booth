import 'package:flutter/material.dart';
import '../models/skill.dart';

class SkillEditor extends StatefulWidget {
  final void Function(Skill skill) onSave;
  const SkillEditor({super.key, required this.onSave});

  @override
  State<SkillEditor> createState() => _SkillEditorState();
}

class _SkillEditorState extends State<SkillEditor> {
  final _skillTitleController = TextEditingController();
  final _skillDescriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add a Skill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skillTitleController,
                decoration: const InputDecoration(labelText: 'Skill Title'),
                validator: (value) => value?.isEmpty == true ? 'Enter skill title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skillDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                validator: (value) => value?.isEmpty == true ? 'Enter a description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(labelText: 'Years of experience'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter years of experience';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave(Skill(
                      title: _skillTitleController.text.trim(),
                      description: _skillDescriptionController.text.trim(),
                      yearsOfExperience: int.parse(_experienceController.text.trim()),
                    ));
                    _skillTitleController.clear();
                    _skillDescriptionController.clear();
                    _experienceController.clear();
                  }
                },
                child: const Text('Add Skill'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
