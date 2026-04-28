import 'package:cloud_firestore/cloud_firestore.dart';
import 'skill.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final String profilePhotoUrl;
  final GeoPoint location;
  final List<Skill> skills;
  final String phoneNumber;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.profilePhotoUrl,
    required this.location,
    required this.skills,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'location': location,
      'skills': skills.map((skill) => skill.toMap()).toList(),
      'phoneNumber': phoneNumber,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      profilePhotoUrl: map['profilePhotoUrl'] as String? ?? '',
      location: map['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      skills: (map['skills'] as List<dynamic>? ?? [])
          .map((skillMap) => Skill.fromMap(Map<String, dynamic>.from(skillMap)))
          .toList(),
      phoneNumber: map['phoneNumber'] as String? ?? '',
    );
  }

  factory UserProfile.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    return UserProfile.fromMap(map);
  }
}
