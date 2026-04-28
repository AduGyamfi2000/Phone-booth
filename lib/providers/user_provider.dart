import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/skill.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/local_cache_service.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseService firebaseService = FirebaseService();
  final LocationService locationService = LocationService();
  final LocalCacheService cacheService = LocalCacheService();

  UserProfile? currentUser;
  List<UserProfile> nearbyProfiles = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  bool mapView = false;

  Future<void> initialize() async {
    try {
      isLoading = true;
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await firebaseService.signInAnonymously();
      }
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null) {
        currentUser = await firebaseService.fetchUserProfile(authUser.uid);
      }
      final cachedProfiles = await cacheService.loadCachedProfiles();
      if (cachedProfiles.isNotEmpty) {
        nearbyProfiles = cachedProfiles;
      }
      await refreshNearbyProfiles();
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNearbyProfiles() async {
    try {
      final position = await locationService.determinePosition();
      final profiles = await firebaseService.searchNearbyProfiles(
        position.latitude,
        position.longitude,
      );
      nearbyProfiles = profiles;
      await cacheService.saveProfiles(profiles);
      notifyListeners();
    } catch (e) {
      if (nearbyProfiles.isEmpty) {
        hasError = true;
        errorMessage = 'Unable to load nearby profiles. ${e.toString()}';
      }
      notifyListeners();
    }
  }

  void toggleMapView() {
    mapView = !mapView;
    notifyListeners();
  }

  Future<void> saveProfile(
    String name,
    String email,
    String bio,
    String phoneNumber,
    GeoPoint location,
    List<Skill> skills,
    File? localPhotoFile,
  ) async {
    try {
      isLoading = true;
      notifyListeners();
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) {
        await firebaseService.signInAnonymously();
      }
      final uid = FirebaseAuth.instance.currentUser!.uid;
      var photoUrl = currentUser?.profilePhotoUrl ?? '';
      if (localPhotoFile != null) {
        photoUrl = await firebaseService.uploadProfilePhoto(uid, localPhotoFile);
      }
      final profile = UserProfile(
        uid: uid,
        name: name,
        email: email,
        bio: bio,
        profilePhotoUrl: photoUrl,
        location: location,
        skills: skills,
        phoneNumber: phoneNumber,
      );
      await firebaseService.saveProfile(profile);
      currentUser = profile;
      notifyListeners();
    } catch (e) {
      hasError = true;
      errorMessage = 'Profile save failed: ${e.toString()}';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
