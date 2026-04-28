import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/skill.dart';
import '../providers/user_provider.dart';
import '../widgets/skill_editor.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<Skill> _skills = [];
  File? _photoFile;
  int _stepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final steps = [
      _buildPersonalInfoStep(),
      _buildSkillsStep(),
      _buildLocationStep(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stepper(
              currentStep: _stepIndex,
              physics: const ClampingScrollPhysics(),
              onStepContinue: _goToNextStep,
              onStepCancel: _goToPreviousStep,
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_stepIndex == steps.length - 1 ? 'Submit' : 'Next'),
                    ),
                    const SizedBox(width: 12),
                    if (_stepIndex > 0)
                      TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
                  ],
                );
              },
              steps: [
                Step(title: const Text('About You'), content: steps[0], isActive: _stepIndex >= 0),
                Step(title: const Text('Skills'), content: steps[1], isActive: _stepIndex >= 1),
                Step(title: const Text('Location'), content: steps[2], isActive: _stepIndex >= 2),
              ],
            ),
            if (provider.isLoading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _photoFile != null ? FileImage(_photoFile!) : null,
              child: _photoFile == null ? const Icon(Icons.camera_alt, size: 44) : null,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (value) => value?.isEmpty == true ? 'Enter your name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value?.contains('@') == true ? null : 'Enter a valid email',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Enter a phone number' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(labelText: 'Bio'),
            maxLines: 4,
            validator: (value) => value?.isEmpty == true ? 'Tell us about yourself' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsStep() {
    return Column(
      children: [
        SkillEditor(
          onSave: (skill) {
            setState(() {
              _skills.add(skill);
            });
          },
        ),
        const SizedBox(height: 16),
        ..._skills.map((skill) => ListTile(
              title: Text(skill.title),
              subtitle: Text('${skill.yearsOfExperience} year(s) • ${skill.description}'),
            )),
      ],
    );
  }

  Widget _buildLocationStep() {
    return const Text('Your current location will be captured automatically when saving your profile.');
  }

  void _goToNextStep() {
    if (_stepIndex == 0 && !_formKey.currentState!.validate()) return;
    if (_stepIndex < 2) {
      setState(() => _stepIndex += 1);
      return;
    }
    _submitProfile();
  }

  void _goToPreviousStep() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex -= 1);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery, imageQuality: 78);
    if (result != null) {
      setState(() {
        _photoFile = File(result.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one skill.')));
      return;
    }

    try {
      final position = await provider.locationService.determinePosition();
      await provider.saveProfile(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _bioController.text.trim(),
        _phoneController.text.trim(),
        GeoPoint(position.latitude, position.longitude),
        _skills,
        _photoFile,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
