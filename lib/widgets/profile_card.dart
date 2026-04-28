import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: profile.profilePhotoUrl.isNotEmpty ? NetworkImage(profile.profilePhotoUrl) : null,
              child: profile.profilePhotoUrl.isEmpty ? const Icon(Icons.person, size: 30) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(profile.bio, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(
                    profile.skills.isNotEmpty ? profile.skills.first.title : 'No skills listed',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
