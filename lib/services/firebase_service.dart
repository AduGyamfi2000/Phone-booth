import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseService() {
    firestore.settings = const Settings(persistenceEnabled: true);
  }

  Future<UserCredential> signInAnonymously() async {
    return auth.signInAnonymously();
  }

  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      final snapshot = await firestore.collection(userCollection).doc(uid).get();
      if (!snapshot.exists) return null;
      return UserProfile.fromDocument(snapshot);
    } catch (e) {
      // If document doesn't exist or permission denied, return null
      if (e.toString().contains('admin-restricted-operation') ||
          e.toString().contains('permission-denied')) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<UserProfile>> searchNearbyProfiles(
    double latitude,
    double longitude,
  ) async {
    const geoDelta = 0.2;
    final minLat = latitude - geoDelta;
    final maxLat = latitude + geoDelta;

    final query = await firestore.collection(userCollection)
        .where('location.latitude', isGreaterThanOrEqualTo: minLat)
        .where('location.latitude', isLessThanOrEqualTo: maxLat)
        .get();

    final candidates = query.docs
        .map((doc) => UserProfile.fromDocument(doc))
        .where((profile) {
          final distance = _distanceInKm(
            latitude,
            longitude,
            profile.location.latitude,
            profile.location.longitude,
          );
          return distance >= minSearchDistanceKm && distance <= maxSearchDistanceKm;
        })
        .toList();

    return candidates;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await firestore.collection(userCollection).doc(profile.uid).set(profile.toMap());
  }

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = storage.ref().child('profile_photos/$uid.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  double _distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_degreesToRadians(lat1)) *
                cos(_degreesToRadians(lat2)) *
                (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * (pi / 180);
}
