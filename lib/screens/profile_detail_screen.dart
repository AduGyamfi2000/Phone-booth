import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_profile.dart';

class ProfileDetailScreen extends StatelessWidget {
  final UserProfile profile;

  const ProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(profile.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 54,
              backgroundImage: profile.profilePhotoUrl.isNotEmpty
                  ? NetworkImage(profile.profilePhotoUrl)
                  : null,
              child: profile.profilePhotoUrl.isEmpty ? const Icon(Icons.person, size: 54) : null,
            ),
            const SizedBox(height: 16),
            Text(profile.bio, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            _DetailTile(label: 'Email', value: profile.email),
            _DetailTile(label: 'Phone', value: profile.phoneNumber),
            _DetailTile(
              label: 'Location',
              value: '${profile.location.latitude.toStringAsFixed(4)}, ${profile.location.longitude.toStringAsFixed(4)}',
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            ...profile.skills.map((skill) => Card(
                  child: ListTile(
                    title: Text(skill.title),
                    subtitle: Text(skill.description),
                    trailing: Text('${skill.yearsOfExperience} yrs'),
                  ),
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _callPhone(profile.phoneNumber),
              icon: const Icon(Icons.phone),
              label: const Text('Call'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _sendEmail(profile.email),
              icon: const Icon(Icons.message),
              label: const Text('Email'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}
